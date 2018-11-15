Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6646B0003
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 02:05:46 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a24-v6so15214410pfn.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 23:05:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 1-v6si28080453plj.53.2018.11.14.23.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 23:05:44 -0800 (PST)
Date: Thu, 15 Nov 2018 07:05:43 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for wraparound check
In-Reply-To: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
Message-Id: <20181115070544.68DEC2089D@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, "Isaac J. Manjarres" <isaacm@codeaurora.org>, keescook@chromium.org, crecklin@redhat.com
Cc: linux-mm@kvack.org, stable@vger.kernel.orgstable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: f5509cc18daa mm: Hardened usercopy.

The bot has tested the following trees: v4.19.2, v4.18.19, v4.14.81, v4.9.137.

v4.19.2: Build OK!
v4.18.19: Build OK!
v4.14.81: Failed to apply! Possible dependencies:
    Unable to calculate

v4.9.137: Failed to apply! Possible dependencies:
    Unable to calculate


--
Thanks,
Sasha
