Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id B82C66B002B
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:34:36 -0500 (EST)
Subject: =?utf-8?q?Re=3A_memory=2Dcgroup_bug?=
Date: Thu, 22 Nov 2012 23:34:34 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121121200207.01068046@pobox.sk>, <20121122152441.GA9609@dhcp22.suse.cz>, <20121122190526.390C7A28@pobox.sk> <20121122214249.GA20319@dhcp22.suse.cz>
In-Reply-To: <20121122214249.GA20319@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121122233434.3D5E35E6@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>

>Btw. is this stack stable or is the task bouncing in some loop?


Not sure, will check it next time.



>And finally could you post the disassembly of your version of
>mem_cgroup_handle_oom, please?


How can i do this?



>What does your kernel log says while this is happening. Are there any
>memcg OOM messages showing up?


I will get the logs next time.


Thank you!

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
