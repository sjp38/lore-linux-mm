Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B90FE6B033D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 10:56:25 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so2931214qtc.22
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 07:56:25 -0800 (PST)
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id t2-v6si4437468qkf.44.2018.11.06.07.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Nov 2018 07:56:24 -0800 (PST)
Date: Tue, 6 Nov 2018 15:56:24 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: page is always non-NULL for node_match()
In-Reply-To: <20181106150245.1668-1-richard.weiyang@gmail.com>
Message-ID: <01000166e9bd3910-c9aad938-d946-4bb9-8383-cf5e24693d16-000000@email.amazonses.com>
References: <20181106150245.1668-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org


Acked-by: Christoph Lameter <cl@linux.com>
