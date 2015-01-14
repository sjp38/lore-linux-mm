Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id BA1D86B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 19:03:42 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id 79so2831767ykr.0
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:03:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f72si11442657yke.32.2015.01.13.16.03.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 16:03:41 -0800 (PST)
Date: Tue, 13 Jan 2015 16:03:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: wrap BUG() branches with unlikely()
Message-Id: <20150113160339.48bca23938e61cda8480f289@linux-foundation.org>
In-Reply-To: <1421102126-3637-1-git-send-email-voytikd@gmail.com>
References: <1421102126-3637-1-git-send-email-voytikd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Voytik <voytikd@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Jan 2015 01:35:26 +0300 Dmitry Voytik <voytikd@gmail.com> wrote:

> Wrap BUG() branches with unlikely() where it is possible. Use BUG_ON()
> instead of "if () BUG();" where it is feasible.

Does this actually do anything?  With my (old) gcc, mm/built-in.o's
size was unaltered.  I didn't check for code generation differences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
