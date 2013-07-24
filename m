Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2F5A26B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 17:02:54 -0400 (EDT)
Message-ID: <51F040E8.1030507@intel.com>
Date: Wed, 24 Jul 2013 14:02:32 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
References: <1374261785-1615-1-git-send-email-kys@microsoft.com> <20130722123716.GB24400@dhcp22.suse.cz> <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com> <51EEA11D.4030007@intel.com> <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com> <51EEA89F.9070309@intel.com> <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com> <51F00415.8070104@sr71.net> <d1f80c05986b439cbeef12bcd595b264@BLUPR03MB050.namprd03.prod.outlook.com>
In-Reply-To: <d1f80c05986b439cbeef12bcd595b264@BLUPR03MB050.namprd03.prod.outlook.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>

On 07/24/2013 12:45 PM, KY Srinivasan wrote:
> All I am saying is that I see two classes of failures: (a) Our
> inability to allocate memory to manage the memory that is being hot added
> and (b) Our inability to bring the hot added memory online within a reasonable
> amount of time. I am not sure the cause for (b) and I was just speculating that
> this could be memory related. What is interesting is that I have seen failure related
> to our inability to online the memory after having succeeded in hot adding the
> memory.

I think we should hold off on this patch and other like it until we've
been sufficiently able to explain how (b) happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
