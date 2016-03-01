Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f177.google.com (mail-yw0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id AA0FE6B0257
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 11:30:21 -0500 (EST)
Received: by mail-yw0-f177.google.com with SMTP id g127so153259031ywf.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:30:21 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id i62si10242892ybc.154.2016.03.01.08.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 08:30:20 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id f6so9601079ywa.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:30:20 -0800 (PST)
Date: Tue, 1 Mar 2016 11:30:18 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] cgroup: reset css on destruction
Message-ID: <20160301163018.GE3965@htj.duckdns.org>
References: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
 <92b11b89791412df49e73597b87912e8f143a3f7.1456830735.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <92b11b89791412df49e73597b87912e8f143a3f7.1456830735.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2016 at 02:13:13PM +0300, Vladimir Davydov wrote:
> @@ -5138,6 +5138,8 @@ static void kill_css(struct cgroup_subsys_state *css)
>  	 * See seq_css() for details.
>  	 */
>  	css_clear_dir(css, NULL);
> +	if (css->ss->css_reset)
> +		css->ss->css_reset(css);

I think the better spot for this is in offline_css() right before
->css_offline() is called.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
