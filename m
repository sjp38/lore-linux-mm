Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4BD26B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 16:10:50 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id i1so1059482ywm.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:10:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b11sor369375ywb.539.2018.03.13.13.10.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 13:10:49 -0700 (PDT)
Date: Tue, 13 Mar 2018 13:10:47 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH V2] mm/memcontrol.c: fix parameter description mismatch
Message-ID: <20180313201047.GE2943022@devbig577.frc2.facebook.com>
References: <1520843448-17347-1-git-send-email-honglei.wang@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1520843448-17347-1-git-send-email-honglei.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Honglei Wang <honglei.wang@oracle.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com

On Mon, Mar 12, 2018 at 04:30:48PM +0800, Honglei Wang wrote:
> There are a couple of places where parameter description and function name
> do not match the actual code. Fix it.
> 
> Signed-off-by: Honglei Wang <honglei.wang@oracle.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
