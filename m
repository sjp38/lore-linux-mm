Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 22D136B005A
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 02:40:29 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so11275602vbk.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 23:40:28 -0800 (PST)
Date: Fri, 23 Nov 2012 08:40:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121123074023.GA24698@dhcp22.suse.cz>
References: <20121121200207.01068046@pobox.sk>
 <20121122152441.GA9609@dhcp22.suse.cz>
 <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121122233434.3D5E35E6@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Thu 22-11-12 23:34:34, azurIt wrote:
[...]
> >And finally could you post the disassembly of your version of
> >mem_cgroup_handle_oom, please?
> 
> How can i do this?

Either use gdb YOUR_VMLINUX and disassemble mem_cgroup_handle_oom or
use objdump -d YOUR_VMLINUX and copy out only mem_cgroup_handle_oom
function.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
