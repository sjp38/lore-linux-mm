Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3697F6B029A
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:42:00 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p74-v6so7547304qka.1
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:42:00 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id k32-v6si910622qtc.318.2018.10.25.06.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 06:41:59 -0700 (PDT)
Date: Thu, 25 Oct 2018 13:41:58 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm, slub: make the comment of put_cpu_partial()
 complete
In-Reply-To: <20181025094437.18951-3-richard.weiyang@gmail.com>
Message-ID: <01000166ab75d745-5552a8fd-dd37-4734-96f1-f0912dab14eb-000000@email.amazonses.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com> <20181025094437.18951-3-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org


Acked-by: Christoph Lameter <cl@linux.com>
