Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 216D56B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 13:52:02 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0OIWZiN019077
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 13:32:35 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 338FA61803D
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 13:47:45 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0OIlitl378158
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 13:47:44 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0OIlikx026464
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 16:47:44 -0200
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110124175807.GA27427@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	 <1295544047.9039.609.camel@nimitz>
	 <20110120180146.GH6335@n2100.arm.linux.org.uk>
	 <1295547087.9039.694.camel@nimitz>
	 <20110123180532.GA3509@n2100.arm.linux.org.uk>
	 <1295887937.11047.119.camel@nimitz>
	 <20110124175807.GA27427@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 24 Jan 2011 10:47:37 -0800
Message-ID: <1295894857.11047.556.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: KyongHo Cho <pullip.cho@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-24 at 17:58 +0000, Russell King - ARM Linux wrote:
> Wrong.  For flatmem, we have a pfn_valid() which is backed by doing a
> one, two or maybe rarely three compare search of the memblocks.  Short
> of having a bitmap of every page in the 4GB memory space, you can't
> get more efficient than that.

Sweet.  So, we can just take the original patch that started this
conversation, add the requisite pfn_valid()s and pfn_to_page()s, and
skip the sparsemem #ifdefs.  Right?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
