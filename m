Message-ID: <478F2CEA.9030905@de.ibm.com>
Date: Thu, 17 Jan 2008 11:24:42 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rft] updated xip patch rollup
References: <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com> <4785D064.1040501@de.ibm.com> <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com> <47872CA7.40802@de.ibm.com> <20080113024410.GA22285@wotan.suse.de> <1200402350.27120.28.camel@cotte.boeblingen.de.ibm.com> <20080116042205.GB29681@wotan.suse.de> <20080116142915.GA19162@wotan.suse.de>
In-Reply-To: <20080116142915.GA19162@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@linux.vnet.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> I've tested it with XIP on brd on x86, both with and without pte_special.
> This covers many (but not all) cases of refcounting.
> 
> Anyway, here it is... assuming no problems, I'll work on making the
> patchset. I'm still hoping we can convince Linus to like it ;)

Works for me. I have tested with dcssblk, and ext2 -o xip on s390x. I 
have bootet a distro and built a kernel with the gcc/glibc being on 
xip file system. Thumbs up :-).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
