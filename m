Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 154A56B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 22:50:57 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Son0w-0006Fc-5q
	for linux-mm@kvack.org; Wed, 11 Jul 2012 04:50:54 +0200
Received: from 112.132.141.1 ([112.132.141.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 04:50:54 +0200
Received: from xiyou.wangcong by 112.132.141.1 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 04:50:54 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
Date: Wed, 11 Jul 2012 02:50:44 +0000 (UTC)
Message-ID: <jtipm3$ov$1@dough.gmane.org>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org>
 <20120709170856.ca67655a.akpm@linux-foundation.org>
 <20120710002510.GB5935@bbox>
 <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com>
 <20120711022304.GA17425@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Wed, 11 Jul 2012 at 02:23 GMT, Minchan Kim <minchan@kernel.org> wrote:
> On Tue, Jul 10, 2012 at 06:02:06PM -0700, David Rientjes wrote:
>> Should we consider enabling CONFIG_COMPACTION in defconfig?  If not, would 
>
> I hope so but Mel didn't like it because some users want to have a smallest
> kernel if they don't care of high-order allocation.
>

If they want a smallest kernel, they probably don't use defconfig,
they should custom their own config.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
