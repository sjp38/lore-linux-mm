Subject: Re: [patch 0/6] mm: bdi: updates
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080129154900.145303789@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Content-Type: text/plain
Date: Tue, 29 Jan 2008 18:06:19 +0100
Message-Id: <1201626379.28547.142.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-29 at 16:49 +0100, Miklos Szeredi wrote:
> This is a series from Peter Zijlstra, with various updates by me.  The
> patchset mostly deals with exporting BDI attributes in sysfs.
> 
> Should be in a mergeable state, at least into -mm.

Thanks for picking these up Miklos!

While they do not strictly depend upon the /proc/<pid>/mountinfo patch I
think its good to mention they go hand in hand. The mountinfo file gives
the information needed to associate a mount with a given bdi for non
block devices.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
