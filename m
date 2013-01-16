Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 964B46B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:21:08 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 18:21:08 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5EF903E4004E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:20:29 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G1KZcP250970
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:20:35 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G1KYZQ027402
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:20:34 -0700
Message-ID: <50F6005B.1010900@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 17:20:27 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/17] mmzone: add various zone_*() helper functions.
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com> <1358295894-24167-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-3-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>

On 01/15/2013 04:24 PM, Cody P Schafer wrote:
> +static inline bool zone_is_empty(struct zone *zone)
> +{
> +	return zone->spanned_pages == 0;
> +}

Why did you choose spanned_pages for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
