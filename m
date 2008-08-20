Date: Wed, 20 Aug 2008 17:31:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] Mlock:  fix return value for munmap/mlock vma race
In-Reply-To: <20080819210533.27199.32744.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook> <20080819210533.27199.32744.sendpatchset@lts-notebook>
Message-Id: <20080820170706.12E2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Against 2.6.27-rc3-mmotm-080819-0259

just note.

atop patch:
	mlock-downgrade-mmap-sem-while-populating-mlocked-regions.patch


> 
> Now, We call downgrade_write(&mm->mmap_sem) at begin of mlock.
> It increase mlock scalability.
> 
> But if mlock and munmap conflict happend, We can find vma gone.
> At that time, kernel should return ENOMEM because mlock after munmap return ENOMEM.
> (in addition, EAGAIN indicate "please try again", but mlock() called again cause error again)
> 
> This problem is theoretical issue.
> I can't reproduce that vma gone on my box, but fixes is better.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
