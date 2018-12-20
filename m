Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 206B28E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 15:51:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so2773189pfj.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:51:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s4si18536622plr.306.2018.12.20.12.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 12:51:25 -0800 (PST)
Date: Thu, 20 Dec 2018 12:51:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [4.20.0-0.rc6] kernel BUG at include/linux/mm.h:990!
Message-Id: <20181220125122.2f674fe4dc290df5ad85d922@linux-foundation.org>
In-Reply-To: <20181219065210.GB10480@dhcp22.suse.cz>
References: <CABXGCsOyHuNpPNMnU0rbMwfGkFA2ooAbkCkyRqC0D-S3ygu-hA@mail.gmail.com>
	<20181217153623.GT30879@dhcp22.suse.cz>
	<CABXGCsNX2akjZqR6CY93=mvEMM7EJKuqHxuCCOQBzKoqk2mbjw@mail.gmail.com>
	<20181219065210.GB10480@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org

On Wed, 19 Dec 2018 07:52:10 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > Any chance that it would be merged in 4.20?
> 
> It is sitting in the mmotm tree. Andrew do you plan to push it to 4.20?
> It seems there are more users suffering from this issue.

OK, I'll send it to Linus this week.
