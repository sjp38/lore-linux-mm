Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7F776B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 04:27:51 -0400 (EDT)
Received: by ewy9 with SMTP id 9so1386364ewy.38
        for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:27:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090317082549.GA5127@orion>
References: <20090317082549.GA5127@orion>
Date: Tue, 17 Mar 2009 11:27:49 +0300
Message-ID: <a4423d670903170127gb874569x544115958be1e7db@mail.gmail.com>
Subject: Re: [PATCH next] slob: fix build problem
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2009/3/17 Alexander Beregalov <a.beregalov@gmail.com>:
> mm/slob.c: In function '__kmalloc_node':
> mm/slob.c:480: error: 'flags' undeclared (first use in this function)

Oh, I see yesterday discussion, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
