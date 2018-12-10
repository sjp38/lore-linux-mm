Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90E788E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 16:09:24 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x7so8998198pll.23
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 13:09:24 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g12si10247943pgh.368.2018.12.10.13.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 13:09:23 -0800 (PST)
Date: Mon, 10 Dec 2018 21:09:22 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the full memory section
In-Reply-To: <20181210130712.30148-2-zaslonko@linux.ibm.com>
References: <20181210130712.30148-2-zaslonko@linux.ibm.com>
Message-Id: <20181210210922.D68472084E@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.orgstable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v4.19.8, v4.14.87, v4.9.144, v4.4.166, v3.18.128, 

v4.19.8: Failed to apply! Possible dependencies:
    Unable to calculate

v4.14.87: Failed to apply! Possible dependencies:
    Unable to calculate

v4.9.144: Failed to apply! Possible dependencies:
    Unable to calculate

v4.4.166: Failed to apply! Possible dependencies:
    Unable to calculate

v3.18.128: Failed to apply! Possible dependencies:
    Unable to calculate


How should we proceed with this patch?

--
Thanks,
Sasha
