Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7D0066B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:04:32 -0400 (EDT)
Date: Mon, 5 Aug 2013 13:31:58 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC PATCH 0/6] Improving munlock() performance for large
 non-THP areas
Message-ID: <20130805173158.GD470@logfs.org>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mgorman@suse.de, linux-mm@kvack.org

On Mon, 5 August 2013 16:31:59 +0200, Vlastimil Babka wrote:
> 
> timedmunlock
>                             3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3
>                                    0                     1                     2                     3                     4                     5                     6
> Elapsed min           3.38 (  0.00%)        3.39 ( -0.14%)        3.00 ( 11.35%)        2.73 ( 19.48%)        2.72 ( 19.50%)        2.34 ( 30.78%)        2.16 ( 36.23%)
> Elapsed mean          3.39 (  0.00%)        3.39 ( -0.05%)        3.01 ( 11.25%)        2.73 ( 19.54%)        2.73 ( 19.41%)        2.36 ( 30.30%)        2.17 ( 36.00%)
> Elapsed stddev        0.01 (  0.00%)        0.00 ( 71.98%)        0.01 (-71.14%)        0.00 ( 89.12%)        0.01 (-48.55%)        0.03 (-277.27%)        0.01 (-85.75%)
> Elapsed max           3.41 (  0.00%)        3.40 (  0.39%)        3.04 ( 10.81%)        2.73 ( 19.96%)        2.76 ( 19.09%)        2.43 ( 28.64%)        2.20 ( 35.41%)
> Elapsed range         0.02 (  0.00%)        0.01 ( 74.99%)        0.04 (-66.12%)        0.00 ( 88.12%)        0.03 (-39.24%)        0.09 (-274.85%)        0.04 (-81.04%)

Impressive numbers.  Patches 1,2,4,6 look good to me (for whatever
that is worth).  Patch 5 exceeded my review capacity for now, I will
give you feedback once my brain returns from vacation.

Thank you for the patchset!  Work in this area is very much
appreciated.

JA?rn

--
The rabbit runs faster than the fox, because the rabbit is rinning for
his life while the fox is only running for his dinner.
-- Aesop

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
