Date: Mon, 7 Jan 2008 22:03:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Fwd: comparion: solaris 10 vs RHEL5 - memory
In-Reply-To: <20080105173952.0b8db5f3@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0801072156120.28838@schroedinger.engr.sgi.com>
References: <6101e8c40801040739i4d7f6e58rbd9b6d68e4565bc7@mail.gmail.com>
 <6101e8c40801040821i495747f2ref1a0df711c23ea@mail.gmail.com>
 <20080105173952.0b8db5f3@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Oliver Pinter (=?UTF-8?B?UGludMOpciBPbGl2w6ly?=)" <oliver.pntr@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 5 Jan 2008, Rik van Riel wrote:

> > Maximum RAM:
> > * 2 TB on current hardware  -> solaris10
> > * 256 GB on X64 -> RHEL5
> 
> The amount listed for RHEL is not the theoretical maximum, but
> the largest amount that has actually been tested. The limits are 
> different per architecture.

We just deployed a Linux system at NASA with 4TB RAM and 4096 cores (IA64).
 
http://www.nas.nasa.gov/

But there are systems with more memory out there like the one in Munich 
with 16TB:

http://192.48.170.160/pdfs/4007.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
