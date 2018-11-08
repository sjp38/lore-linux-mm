Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71A9D6B0678
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 17:52:43 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id j13-v6so19322366pff.0
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 14:52:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g74-v6si5882311pfe.4.2018.11.08.14.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 14:52:42 -0800 (PST)
Date: Thu, 8 Nov 2018 14:52:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm:vmalloc add vm_struct for vm_map_ram
Message-Id: <20181108145239.f8249da5833974bad286fb78@linux-foundation.org>
In-Reply-To: <1541675689-13363-1-git-send-email-huangzhaoyang@gmail.com>
References: <1541675689-13363-1-git-send-email-huangzhaoyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, David Rientjes <rientjes@google.com>, Joe Perches <joe@perches.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  8 Nov 2018 19:14:49 +0800 Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:

> There is no caller and pages information etc for the area which is
> created by vm_map_ram as well as the page count > VMAP_MAX_ALLOC.
> Add them on in this commit.

Well I can kind of see what this is doing - it increases the amount of
info in /proc/vmallocinfo for regions which were created by
vm_map_area(), yes?

But I'd like to hear it in your words, please.  What problem are we
trying to solve?  Why is it actually a problem?  Why is the additional
information considered useful, etc?

It would help a lot if the changelog were to include before-and-after
examples from the /proc/vmallocinfo output.

Thanks.
