From: Matthew Wilcox <matthew@wil.cx>
Subject: [LSF/MM TOPIC] Persistent Memory
Date: Fri, 20 Dec 2013 10:05:02 -0700
Message-ID: <20131220170502.GF19166@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org


I should like to discuss the current situation with Linux support for
persistent memory.  While I expect the current discussion to be long
over by March, I am certain that there will be topics around persistent
memory that have not been settled at that point.

I believe this will mostly be of crossover interest between filesystem
and MM people, and of lesser interest to storage people (since we're
basically avoiding their code).

Subtopics might include
 - Using persistent memory for FS metadata
   (The XIP code provides persistent memory to userspace.  The filesystem
    still uses BIOs to fetch its metadata)
 - Supporting PMD/PGD mappings for userspace
   (Not only does the filesystem have to avoid fragmentation to make this
    happen, the VM code has to permit these giant mappings)
 - Persistent page cache
   (Another way to take advantage of persstent memory would be to place it
    in the page cache.  But we don't have struct pages for it!  What to do?)
 - Making XIP and non-XIP codepaths closer to each other
   (I think we have a good start on this, but more is needed)

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
