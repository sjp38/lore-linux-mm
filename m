Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DCF486B00DC
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:18:51 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5939000pad.16
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 04:18:51 -0700 (PDT)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id sj5si10210485pab.52.2013.10.27.04.18.50
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 04:18:50 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id n9so3235216qcw.15
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 04:18:48 -0700 (PDT)
Date: Sun, 27 Oct 2013 07:18:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu counter: test module
Message-ID: <20131027111844.GA14934@mtj.dyndns.org>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
 <1382859876-28196-2-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382859876-28196-2-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 27, 2013 at 12:44:34AM -0700, Greg Thelen wrote:
> Tests various percpu operations.
> 
> Enable with CONFIG_PERCPU_TEST=m.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
