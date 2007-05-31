Date: Thu, 31 May 2007 00:05:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/41] fs: introduce write_begin, write_end, and
 perform_write aops
Message-Id: <20070531000539.7386646c.akpm@linux-foundation.org>
In-Reply-To: <20070531051539.GK20107@wotan.suse.de>
References: <20070524052844.860329000@suse.de>
	<20070524053155.065366000@linux.local0.net>
	<20070530213035.d7b6e3e0.akpm@linux-foundation.org>
	<20070531044327.GD20107@wotan.suse.de>
	<20070530215231.468e7f26.akpm@linux-foundation.org>
	<20070531045754.GE20107@wotan.suse.de>
	<20070530221121.7eadc807.akpm@linux-foundation.org>
	<20070531051539.GK20107@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 31 May 2007 07:15:39 +0200 Nick Piggin <npiggin@suse.de> wrote:

> If you can send that rollup, it would be good. I could try getting
> everything to compile and do some more testing on it too.


Single patch against 2.6.22-rc3: http://userweb.kernel.org/~akpm/np.gz

broken-out: ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/broken-out-2007-05-30-09-30.tar.gz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
