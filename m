Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 127DD6B0088
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 05:10:39 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb30so2920788vcb.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 02:10:38 -0800 (PST)
Date: Fri, 23 Nov 2012 11:10:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121123101034.GG24698@dhcp22.suse.cz>
References: <20121121200207.01068046@pobox.sk>
 <20121122152441.GA9609@dhcp22.suse.cz>
 <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123092829.GE24698@dhcp22.suse.cz>
 <20121123104423.338C7725@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121123104423.338C7725@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Fri 23-11-12 10:44:23, azurIt wrote:
[...]
> # gdb vmlinux 
> GNU gdb (GDB) 7.0.1-debian
> Copyright (C) 2009 Free Software Foundation, Inc.
> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
> This is free software: you are free to change and redistribute it.
> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
> and "show warranty" for details.
> This GDB was configured as "x86_64-linux-gnu".
> For bug reporting instructions, please see:
> <http://www.gnu.org/software/gdb/bugs/>...
> Reading symbols from /root/bug/dddddddd/vmlinux...(no debugging symbols found)...done.
> (gdb) disassemble mem_cgroup_handle_oom
> No symbol table is loaded.  Use the "file" command.
> 
> 
> 
> # objdump -d vmlinux | grep mem_cgroup_handle_oom
> <no output>

Hmm, strange so the function is on the stack but it has been inlined?
Doesn't make much sense to me.

> i can recompile the kernel if anything needs to be added into it.

If you could instrument mem_cgroup_handle_oom with some printks (before
we take the memcg_oom_lock, before we schedule and into
mem_cgroup_out_of_memory)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
