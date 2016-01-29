Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 08A986B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 04:50:32 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id r129so60690900wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 01:50:31 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id dz12si21021354wjb.180.2016.01.29.01.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 01:50:30 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id r129so60690127wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 01:50:30 -0800 (PST)
Date: Fri, 29 Jan 2016 11:50:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Message-ID: <20160129095028.GA10767@node.shutemov.name>
References: <20160128175536.GA20797@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160128175536.GA20797@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 28, 2016 at 06:55:37PM +0100, Jerome Glisse wrote:
> Hi,
> 
> I would like to attend LSF/MM this year to discuss about HMM
> (Heterogeneous Memory Manager) and more generaly all topics
> related to GPU and heterogeneous memory architecture (including
> persistent memory).

How is persistent memory heterogeneous?

I thought it's either in the same cache coherency domain (DAX case) or is
not a memory for kernel -- behind block layer.
Do we have yet another option?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
