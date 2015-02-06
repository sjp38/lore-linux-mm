Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 52FBB6B0078
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 17:28:41 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hi2so339542wib.3
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 14:28:40 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id p2si6496442wjx.204.2015.02.06.14.28.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 14:28:40 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id x13so16262328wgg.1
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 14:28:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1423259664.git.tony.luck@intel.com>
References: <cover.1423259664.git.tony.luck@intel.com>
Date: Fri, 6 Feb 2015 14:28:38 -0800
Message-ID: <CA+8MBbJqmSBFBNwh2kQkTXf0hFjRd2tCSgTKsRRxYFXv6TQMaA@mail.gmail.com>
Subject: Re: [RFC 0/3] Mirrored memory support for boot time allocations
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Feb 6, 2015 at 1:54 PM, Tony Luck <tony.luck@intel.com> wrote:
> Platforms that support a mix of mirrored and regular memory are coming.

Obviously I don't do enough -mm work to remember where linux-mm mailing list
is hosted :-(

Let's see who finds this on the linux-kernel list (that I did spell
right).  When v2
happens I'll get it to the right places.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
