Subject: Re: 2.5.33-mm1
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <3D764A9F.B296F6C0@zip.com.au>
References: <3D75CD24.AF9B769B@zip.com.au>
	<1031159814.23852.21.camel@plars.austin.ibm.com>
	<3D764A9F.B296F6C0@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Sep 2002 15:07:29 -0500
Message-Id: <1031170050.24570.24.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-09-04 at 13:02, Andrew Morton wrote:
> hm.  We seem to have a corrupted slabp->list.  I don't recall any
> slab fixes post 2.3.33-mm1.  hm.
> 
> Questions, please: how much physical memory, how many CPUs?

8 CPU PIII-700
16 GB physical ram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
