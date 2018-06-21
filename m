Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5ABEA6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 04:09:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t7-v6so1367855wmg.3
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:09:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12-v6si2599738edi.394.2018.06.21.01.09.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 01:09:29 -0700 (PDT)
Date: Thu, 21 Jun 2018 10:09:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180621080927.GE10465@dhcp22.suse.cz>
References: <20180620103736.13880-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180620103736.13880-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

This is an updated version with feedback from Johannes integrated. Still
not runtime tested but I am posting it to make further review easier.
