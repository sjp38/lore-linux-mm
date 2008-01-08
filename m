Message-ID: <47836681.8070603@de.ibm.com>
Date: Tue, 08 Jan 2008 13:03:13 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
References: <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <20080108100803.GA24570@wotan.suse.de> <47835FBE.8080406@de.ibm.com> <20080108115536.GB460@wotan.suse.de>
In-Reply-To: <20080108115536.GB460@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Oh good. So just to clarify -- I guess you guys have a readonly filesystem
> containing the distro on the host, and mount it XIP on each guest... avoiding
> struct page means you save a bit of memory on each guest?
That's right. It's quite a bit of memory for struct page entries, 
because we'd love to have an entire distro with a superset of packages 
for each guest being installed on the filesystem (-- large shared 
segment). And we're talking 3 digits amount of guests here. This is a 
real benefit in our scenario.

>> But I really really want to exchange patch #4 with a 
>> pte-bit based one before pushing this.
> OK fair enough, let's do that.
Thanks, am on it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
