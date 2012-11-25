Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 330286B0068
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 08:44:43 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so4106412eaa.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2012 05:44:41 -0800 (PST)
Date: Sun, 25 Nov 2012 14:44:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121125134440.GD10623@dhcp22.suse.cz>
References: <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121123155904.490039C5@pobox.sk>
 <20121125101707.GA10623@dhcp22.suse.cz>
 <20121125133953.AD1B2F0A@pobox.sk>
 <20121125130208.GC10623@dhcp22.suse.cz>
 <20121125142709.19F4E8C2@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121125142709.19F4E8C2@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Sun 25-11-12 14:27:09, azurIt wrote:
> >> Thank you very much, i will install it ASAP (probably this night).
> >
> >Please don't. If my analysis is correct which I am almost 100% sure it
> >is then it would cause excessive logging. I am sorry I cannot come up
> >with something else in the mean time.
> 
> 
> Ok then. I will, meanwhile, try to contact Andrea Righi (author of
> cgroup-task etc.) and ask him to send here his opinion about relation
> between freezes and his patches.

As I described in other email. This seems to be a deadlock in memcg oom
so I do not think that other patches influence this.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
