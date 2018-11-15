Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0056B000A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:53:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 98so43442465qkp.22
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 01:53:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r25si1490385qtt.10.2018.11.15.01.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 01:53:52 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
 <20181114145250.GE2653@MiWiFi-R3L-srv>
 <20181114150029.GY23419@dhcp22.suse.cz>
 <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
 <20181115075349.GL2653@MiWiFi-R3L-srv>
 <20181115083055.GD23831@dhcp22.suse.cz>
 <a1d4aa33-5c6d-1a6d-1426-46b2cebbf57e@redhat.com>
 <20181115095225.GO2653@MiWiFi-R3L-srv>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d5ae825a-90ed-b7e2-ee71-e18c87c83d1a@redhat.com>
Date: Thu, 15 Nov 2018 10:53:40 +0100
MIME-Version: 1.0
In-Reply-To: <20181115095225.GO2653@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On 15.11.18 10:52, Baoquan He wrote:
> On 11/15/18 at 10:42am, David Hildenbrand wrote:
>> I am wondering why it is always the last memory block of that device
>> (and even that node). Coincidence?
> 
> I remember one or two times it's the last 6G or 4G which stall there,
> the size of memory block is 2G. But most of time it's the last memory
> block. And from the debug printing added by Michal's patch, it's the
> stress program itself which owns the migrating page and loop forvever
> there.
> 

Alright, seems like you found a very good reproducer for an existing
problem :)

-- 

Thanks,

David / dhildenb
