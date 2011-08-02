Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C440D900163
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 21:09:38 -0400 (EDT)
Subject: Re: questions about memory hotplug
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110801170850.GB3466@labbmf-linux.qualcomm.com>
References: <20110729221230.GA3466@labbmf-linux.qualcomm.com>
	 <20110730093055.GA10672@sli10-conroe.sh.intel.com>
	 <20110801170850.GB3466@labbmf-linux.qualcomm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Aug 2011 09:09:36 +0800
Message-ID: <1312247376.15392.454.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 2011-08-02 at 01:08 +0800, Larry Bassel wrote:
> 
> In use case #1 yes, maybe not in #2 (we can arrange it to be
> at the end of memory, but then might waste memory as it may
> not be aligned on a SPARSEMEM section boundary and so would
> need to be padded).
then maybe the new migrate type I suggested can help here for the
non-aligned memory. Anyway, let me do an experiment.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
