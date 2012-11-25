Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 80A826B0068
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 08:02:11 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so7192279eek.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2012 05:02:09 -0800 (PST)
Date: Sun, 25 Nov 2012 14:02:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121125130208.GC10623@dhcp22.suse.cz>
References: <20121122152441.GA9609@dhcp22.suse.cz>
 <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121123155904.490039C5@pobox.sk>
 <20121125101707.GA10623@dhcp22.suse.cz>
 <20121125133953.AD1B2F0A@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121125133953.AD1B2F0A@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Sun 25-11-12 13:39:53, azurIt wrote:
> >Inlined at the end of the email. Please note I have compile tested
> >it. It might produce a lot of output.
> 
> 
> Thank you very much, i will install it ASAP (probably this night).

Please don't. If my analysis is correct which I am almost 100% sure it
is then it would cause excessive logging. I am sorry I cannot come up
with something else in the mean time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
