Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 791F16B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 11:24:45 -0500 (EST)
Date: Thu, 8 Mar 2012 16:24:41 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: decode GFP flags in oom killer output.
Message-ID: <20120308162441.GG17697@suse.de>
References: <20120307233939.GB5574@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120307233939.GB5574@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Mar 07, 2012 at 06:39:39PM -0500, Dave Jones wrote:
> Decoding these flags by hand in oom reports is tedious,
> and error-prone.
> 

It's not really a proper solution but scripts/gfp-translate is less
error-prone than doing it by hand but requires that you have the kernel
source available.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
