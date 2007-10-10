Date: Wed, 10 Oct 2007 11:32:04 +0100
Subject: Re: where to get ZONE_MOVABLE pathces?
Message-ID: <20071010103204.GB16361@skynet.ie>
References: <20071004035935.042951211@sgi.com> <200710091846.22796.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710091825470.4500@schroedinger.engr.sgi.com> <200710091956.30487.nickpiggin@yahoo.com.au> <037701c80aee$c6cd32d0$3708a8c0@arcapub.arca.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <037701c80aee$c6cd32d0$3708a8c0@arcapub.arca.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jacky(GuangXiang  Lee)" <gxli@arca.com.cn>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (10/10/07 11:36), Jacky(GuangXiang  Lee) didst pronounce:
> hi list ,
> 
> I am looking for Mel's patch about ZONE_MOVABLE
> http://kerneltrap.org/mailarchive/linux-kernel/2007/1/25/48006
> 
> Who can tell me where to download those patches?

They are already in mainline. Check out the latest kernel and look at
Documentation/kernel-parameters.txt for the kernelcore= and movablecore=
parameters.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
