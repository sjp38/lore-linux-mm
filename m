Message-ID: <468D6569.6050606@redhat.com>
Date: Thu, 05 Jul 2007 17:40:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: vm/fs meetup details
References: <20070705040138.GG32240@wotan.suse.de> <468D303E.4040902@redhat.com> <137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com> <20070705212757.GB12413810@sgi.com>
In-Reply-To: <20070705212757.GB12413810@sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Zach Brown <zach.brown@oracle.com>, Nick Piggin <npiggin@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Chris Mason <chris.mason@oracle.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Joern Engel <joern@logfs.org>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Chinner wrote:
> On Thu, Jul 05, 2007 at 01:40:08PM -0700, Zach Brown wrote:
>>> - repair driven design, we know what it is (Val told us), but
>>>  how does it apply to the things we are currently working on?
>>>  should we do more of it?
>> I'm sure Chris and I could talk about the design elements in btrfs  
>> that should aid repair if folks are interested in hearing about  
>> them.  We'd keep the hand-waving to a minimum :).
> 
> And I'm sure I could provide a counterpoint by talking about
> the techniques we've used improving XFS repair speed and
> scalability without needing to change any on disk formats....

Sounds like that could be an interesting discussion.

Especially when trying to answer questions like:

"At what filesystem size will the mitigating fixes no
  longer be enough?"

and

"When will people start using filesystems THAT big?"  :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
