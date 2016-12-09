Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1EFF6B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 08:40:40 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so7254983wjb.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 05:40:40 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ke2si34100545wjb.49.2016.12.09.05.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 05:40:27 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a20so4146718wme.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 05:40:27 -0800 (PST)
Date: Fri, 9 Dec 2016 14:40:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er kernels
Message-ID: <20161209134025.GB4342@dhcp22.suse.cz>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 09-12-16 08:06:25, Gerhard Wiesinger wrote:
> Hello,
> 
> same with latest kernel rc, dnf still killed with OOM (but sometimes
> better).
> 
> ./update.sh: line 40:  1591 Killed                  ${EXE} update ${PARAMS}
> (does dnf clean all;dnf update)
> Linux database.intern 4.9.0-0.rc8.git2.1.fc26.x86_64 #1 SMP Wed Dec 7
> 17:53:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
> 
> Updated bug report:
> https://bugzilla.redhat.com/show_bug.cgi?id=1314697

Could you post your oom report please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
