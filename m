Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9D2CB6B0027
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 12:29:08 -0400 (EDT)
Date: Mon, 18 Mar 2013 17:29:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Support 2M page allocations
 for ballooning
Message-ID: <20130318162906.GV10192@dhcp22.suse.cz>
References: <1363470088-24565-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-2-git-send-email-kys@microsoft.com>
 <20130318105257.GG10192@dhcp22.suse.cz>
 <1701384b10204014b53acecb006521b0@SN2PR03MB061.namprd03.prod.outlook.com>
 <20130318141302.GO10192@dhcp22.suse.cz>
 <98cd176931934b59a0fcb1ec3448d86c@SN2PR03MB061.namprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <98cd176931934b59a0fcb1ec3448d86c@SN2PR03MB061.namprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>

On Mon 18-03-13 15:08:36, KY Srinivasan wrote:
> What is your recommendation with regards which tree the mm patch needs
> to go through; the Hyper-V balloon driver patch will go through Greg's
> tree.

I would say via Andrew but there are dependencies between those two so a
single tree would be less confusing /me thinks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
