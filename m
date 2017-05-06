Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E90E6B02C4
	for <linux-mm@kvack.org>; Sat,  6 May 2017 03:47:32 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id m78so5367556vkf.8
        for <linux-mm@kvack.org>; Sat, 06 May 2017 00:47:32 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id z1si2922790uaz.155.2017.05.06.00.47.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 May 2017 00:47:31 -0700 (PDT)
Message-ID: <1494056846.25766.420.camel@kernel.crashing.org>
Subject: Re: Is iounmap(NULL) safe or not?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 06 May 2017 09:47:26 +0200
In-Reply-To: <1494024608-10343-1-git-send-email-khoroshilov@ispras.ru>
References: <1494024608-10343-1-git-send-email-khoroshilov@ispras.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org

On Sat, 2017-05-06 at 01:50 +0300, Alexey Khoroshilov wrote:
> Could you please clarify if iounmap(NULL) safe or not.
> I guess it would be less errorprone if the answer is architecture independent.

I think it's supposed to be and we should fix ppc.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
