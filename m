Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D76B6B0269
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:17:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 87-v6so3023420pfq.8
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:17:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d186-v6si22875628pfg.23.2018.10.09.15.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 15:17:41 -0700 (PDT)
Date: Tue, 9 Oct 2018 15:17:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: zero-seek shrinkers
Message-Id: <20181009151740.eaa1e07b111b4f4d90d0172c@linux-foundation.org>
In-Reply-To: <20181009151556.5b0a3c9ae270b7551b3d12e6@linux-foundation.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	<20181009184732.762-5-hannes@cmpxchg.org>
	<20181009151556.5b0a3c9ae270b7551b3d12e6@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 9 Oct 2018 15:15:56 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> Seems sane, but I'm somewhat worried about unexpected effects on other
> workloads.  So I think I'll hold this over for 4.20.  Or shouldn't I?

Meant 4.21.  But on reflection this is perhaps excessively cautious.
