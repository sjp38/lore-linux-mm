Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27BAC6B04AA
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 19:22:11 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a72-v6so13894432pfj.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 16:22:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i11-v6si33004816pgk.29.2018.11.06.16.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 16:22:09 -0800 (PST)
Date: Tue, 6 Nov 2018 16:22:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
Message-Id: <20181106162206.0f43c1eb16c3dd812bdadbdd@linux-foundation.org>
In-Reply-To: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Oct 2018 16:30:58 +0530 Arun KS <arunks@codeaurora.org> wrote:

> This series convert totalram_pages, totalhigh_pages and
> zone->managed_pages to atomic variables.

The whole point appears to be removal of managed_page_count_lock, yes?

Why?  What is the value of this patchset?  If "performance" then are any
measurements available?
