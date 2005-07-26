Date: Tue, 26 Jul 2005 14:24:10 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Memory pressure handling with iSCSI
Message-Id: <20050726142410.4ff2e56a.akpm@osdl.org>
In-Reply-To: <1122412301.6433.54.camel@dyn9047017102.beaverton.ibm.com>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	<20050726111110.6b9db241.akpm@osdl.org>
	<1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	<20050726114824.136d3dad.akpm@osdl.org>
	<20050726121250.0ba7d744.akpm@osdl.org>
	<1122412301.6433.54.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> ext2 is incredibly better. Machine is very responsive. 
> 

OK.  Please, always monitor and send /proc/meminfo.  I assume that the
dirty-memory clamping is working OK with ext2 and that perhaps it'll work
OK with ext3/data=writeback.

All very odd.  I wonder how to reproduce this.  Maybe 50 ext3 filesystems
on regular old scsi will do it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
