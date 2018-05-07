Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6388B6B0010
	for <linux-mm@kvack.org>; Mon,  7 May 2018 03:56:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id z18-v6so1931769lfg.17
        for <linux-mm@kvack.org>; Mon, 07 May 2018 00:56:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22-v6sor2521808lje.54.2018.05.07.00.56.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 00:56:08 -0700 (PDT)
Message-Id: <20180507075213.386076821@gmail.com>
Date: Mon, 07 May 2018 10:52:13 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [rfc linux-next 0/3] prctl: prctl_set_mm -- Bring back handling of PR_SET_MM_x
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jonathan de Boyne Pollard <J.deBoynePollard-newsgroups@NTLWorld.COM>, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linuxfoundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>

Hi! Yesterday I've been pointed out that we unfortunatelly can't
drop off PR_SET_MM_x operations. So here is a series which bring
them back but instead of plain revert I tried to simplify the
code and make it as minimum as possible.

WARN: the series is compile-tested only for a while, I wanted
to share it early so maybe someone has better idea of how
integrate old PR_SET_MM_x operations. I'll do full tests
today hopefully.

	Cyrill
