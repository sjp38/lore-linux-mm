Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 2C7F56B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:01:10 -0400 (EDT)
Message-ID: <51EEA89F.9070309@intel.com>
Date: Tue, 23 Jul 2013 09:00:31 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
References: <1374261785-1615-1-git-send-email-kys@microsoft.com> <20130722123716.GB24400@dhcp22.suse.cz> <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com> <51EEA11D.4030007@intel.com> <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
In-Reply-To: <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>

On 07/23/2013 08:54 AM, KY Srinivasan wrote:
>> > Adding memory usually requires allocating some large, contiguous areas
>> > of memory for use as mem_map[] and other VM structures.  That's really
>> > hard to do under heavy memory pressure.  How are you accomplishing this?
> I cannot avoid failures because of lack of memory. In this case I notify the host of
> the failure and also tag the failure as transient. Host retries the operation after some
> delay. There is no guarantee it will succeed though.

You didn't really answer the question.

You have allocated some large, physically contiguous areas of memory
under heavy pressure.  But you also contend that there is too much
memory pressure to run a small userspace helper.  Under heavy memory
pressure, I'd expect large, kernel allocations to fail much more often
than running a small userspace helper.

It _sounds_ like you really want to be able to have the host retry the
operation if it fails, and you return success/failure from inside the
kernel.  It's hard for you to tell if running the userspace helper
failed, so your solution is to move what what previously done in
userspace in to the kernel so that you can more easily tell if it failed
or succeeded.

Is that right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
