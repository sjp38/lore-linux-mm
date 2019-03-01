Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C62CDC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E4A92087E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E4A92087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8C58E0003; Fri,  1 Mar 2019 08:21:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E88228E0001; Fri,  1 Mar 2019 08:21:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D77008E0003; Fri,  1 Mar 2019 08:21:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2B18E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 08:21:15 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u12so10048749edo.5
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 05:21:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=bJbLK0iw8DP6sCW6MXu4Evb27zKftcAqm8hiesLhVTk=;
        b=JulOz9y4Ynd587d94qfcjBXrkndBa2eE3QG2U+lArb39mMVRTYSJI+H0Cj0wsb9XP8
         WdwBuCw6LjJxLUKhBvDwKK1jgYZ4FzB2wNh3mVmqk1T22MzbyNASVt/FXA3WPKH6snQu
         4b+lpaS48VorDObSXKclXf/OSgKHQzW2jkrgVWttPOOo6ZCVZW/3Y3y6d5ug7p3OujPw
         Wt8cBsq2R/Fobd708BjHo3UBbdHD6VLx+d8a6mpdkez5iEvMJqinqWPNKsXGetw5eVy5
         As/3vdJBvJwmB9rEBGBkQMRDYjvaM1Ej5+Hu+314xi0J4RxnE8BURartLQVr+4NwP21v
         oxSg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAX4W/GoB5aybSJcubN/VAkX2Y509h26dQmwtNUZMdHMQPzirJ5I
	oA/TE9lauuKi+wEk79jH7Dsf6vsVzxyuyV3R5ZvwzLYp0ROO40HHJnv9HSJ9kiNTL5wf9QPN8sr
	0K3dj4aGG68LZmNO62FGhrj1r+7fwDJEGJvg9E6Yk9i3ZBBZmFvOIlKIohJ9PH6s=
X-Received: by 2002:a50:ac55:: with SMTP id w21mr4248504edc.121.1551446474973;
        Fri, 01 Mar 2019 05:21:14 -0800 (PST)
X-Google-Smtp-Source: APXvYqwyTb1zDLCSR30nK8hkYFPUCvuDAY6JNknWBbxMBMZG55rqq22cMi7yLJ+onJXw1Fo3RpgL
X-Received: by 2002:a50:ac55:: with SMTP id w21mr4248435edc.121.1551446473712;
        Fri, 01 Mar 2019 05:21:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551446473; cv=none;
        d=google.com; s=arc-20160816;
        b=dyWg/Tx/6gi9w8kMlUVgC9LEiQCKLU8QXadiuObzNimQr0TCCtUp406K37b6j/46GG
         EcMpuNxjL5Y5UzFb5ePbC5Ij3PwqWDm2IgS+K0Jd/uRV02wxlQV4+tE5vnH1PUWc6c4n
         BODxvpeN1H5nC8WeG3FjlISojFRWxxtU0ywJVZis2Nd+goYN0Yq/1d/JDvPL4huZ11IG
         JYXCf5pNTpa/V8Z9HfkvfD3V71KQ94MCwTx9ufjiFM3RuexfhcmOv0A7X3p9cUkVUW7d
         ux63evgeFcLPFK/BEms6v59L5DrmRyErSQ1Cwua1bdKMHsq8Nzk6jq4pIE3XLeu3oy65
         l1Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=bJbLK0iw8DP6sCW6MXu4Evb27zKftcAqm8hiesLhVTk=;
        b=TFri9DK+iLCyZottQePCXHGqNoE1rLIY0FavPTXtKuRLct6dvT8wMBK+7y3Qye5xi9
         b9UxproM9Rs+lJVK5XLhvkYJlR/sD2fbR9S03u5V2IJ039jut123f29fM5ZnovpaYBP2
         DSXH/Orqx3QBovQ3xv7WQ0XAliACdDLdQFQ83HaSKOSy2Bztc8DjKm9j6K9DDnorcO4x
         h5EZ4RvY4xqpSL9wb310Fx3TVq/+vEgKiqh4G1zbcprZgNqKQMSDJcNWLKus0Ln5l536
         PHjyvkzwqmzCAzuyCdcldxwhTFv8zr2DyKkLNrz5p3s78ksPIb4Pskx7JPG7PF6XYVSJ
         24zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id r50si8693632edd.257.2019.03.01.05.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 05:21:13 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id ABA561C001D;
	Fri,  1 Mar 2019 13:21:06 +0000 (UTC)
Subject: Re: [PATCH v4 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
From: Alexandre Ghiti <alex@ghiti.fr>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190228063604.15298-1-alex@ghiti.fr>
 <20190228063604.15298-5-alex@ghiti.fr>
 <9a385cc8-581c-55cf-4a85-10b5c4dd178c@intel.com>
 <31212559-d397-88fb-eaec-60f6417436c8@oracle.com>
 <6c842251-1bed-4d79-bf6d-997006ec72e2@intel.com>
 <6ea4119a-0ecb-511d-3aab-269004245a08@oracle.com>
 <1cfaca88-a219-d057-3ab8-37fb1c1687d6@ghiti.fr>
Message-ID: <f7c94eb5-d496-7e24-d44f-17eaff287012@ghiti.fr>
Date: Fri, 1 Mar 2019 14:21:06 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <1cfaca88-a219-d057-3ab8-37fb1c1687d6@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/01/2019 07:25 AM, Alex Ghiti wrote:
> On 2/28/19 5:26 PM, Mike Kravetz wrote:
>> On 2/28/19 12:23 PM, Dave Hansen wrote:
>>> On 2/28/19 11:50 AM, Mike Kravetz wrote:
>>>> On 2/28/19 11:13 AM, Dave Hansen wrote:
>>>>>> +    if (hstate_is_gigantic(h) && 
>>>>>> !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
>>>>>> +        spin_lock(&hugetlb_lock);
>>>>>> +        if (count > persistent_huge_pages(h)) {
>>>>>> +            spin_unlock(&hugetlb_lock);
>>>>>> +            return -EINVAL;
>>>>>> +        }
>>>>>> +        goto decrease_pool;
>>>>>> +    }
>>>>> This choice confuses me.  The "Decrease the pool size" code already
>>>>> works and the code just falls through to it after skipping all the
>>>>> "Increase the pool size" code.
>>>>>
>>>>> Why did did you need to add this case so early?  Why not just let it
>>>>> fall through like before?
>>>> I assume you are questioning the goto, right?  You are correct in that
>>>> it is unnecessary and we could just fall through.
>>> Yeah, it just looked odd to me.
>
> (Dave I do not receive your answers, I don't know why).

I collected mistakes here: domain name expired and no mailing list added :)
Really sorry about that, I missed the whole discussion (if any).
Could someone forward it to me (if any) ? Thanks !

> I'd rather avoid useless checks when we already know they won't
> be met and I think that makes the code more understandable.
>
> But that's up to you for the next version.
>
> Thanks
>>>
>>>> However, I wonder if we might want to consider a wacky condition 
>>>> that the
>>>> above check would prevent.  Consider a system/configuration with 5 
>>>> gigantic
>>>> pages allocated at boot time.  Also CONFIG_CONTIG_ALLOC is not 
>>>> enabled, so
>>>> it is not possible to allocate gigantic pages after boot.
>>>>
>>>> Suppose the admin decreased the number of gigantic pages to 3.  
>>>> However, all
>>>> gigantic pages were in use.  So, 2 gigantic pages are now 'surplus'.
>>>> h->nr_huge_pages == 5 and h->surplus_huge_pages == 2, so
>>>> persistent_huge_pages() == 3.
>>>>
>>>> Now suppose the admin wanted to increase the number of gigantic 
>>>> pages to 5.
>>>> The above check would prevent this.  However, we do not need to really
>>>> 'allocate' two gigantic pages.  We can simply convert the surplus 
>>>> pages.
>>>>
>>>> I admit this is a wacky condition.  The ability to 'free' gigantic 
>>>> pages
>>>> at runtime if !CONFIG_CONTIG_ALLOC makes it possible.  I don't 
>>>> necessairly
>>>> think we should consider this.  hugetlbfs code just makes me think of
>>>> wacky things. :)
>>> I think you're saying that the newly-added check is overly-restrictive.
>>>   If we "fell through" like I was suggesting we would get better 
>>> behavior.
>> At first, I did not think it overly restrictive.  But, I believe we can
>> just eliminate that check for gigantic pages.  If 
>> !CONFIG_CONTIG_ALLOC and
>> this is a request to allocate more gigantic pages, 
>> alloc_pool_huge_page()
>> should return NULL.
>>
>> The only potential issue I see is that in the past we have returned 
>> EINVAL
>> if !CONFIG_CONTIG_ALLOC and someone attempted to increase the pool size.
>> Now, we will not increase the pool and will not return an error.  Not 
>> sure
>> if that is an acceptable change in user behavior.
>
> If I may, I think that this is the kind of info the user wants to have 
> and we should
> return an error when it is not possible to allocate runtime huge pages.
> I already noticed that if someone asks for 10 huge pages, and only 5 
> are allocated,
> no error is returned to the user and I found that surprising.
>
>>
>> If we go down this path, then we could remove this change as well:
>
> I agree that in that path, we do not need the following change neither.
>
>>
>>> @@ -2428,7 +2442,9 @@ static ssize_t 
>>> __nr_hugepages_store_common(bool obey_mempolicy,
>>>       } else
>>>           nodes_allowed = &node_states[N_MEMORY];
>>>   -    h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
>>> +    err = set_max_huge_pages(h, count, nodes_allowed);
>>> +    if (err)
>>> +        goto out;
>>>         if (nodes_allowed != &node_states[N_MEMORY])
>>>           NODEMASK_FREE(nodes_allowed);
>> Do note that I beleive there is a bug the above change.  The code after
>> the out label is:
>>
>> out:
>>          NODEMASK_FREE(nodes_allowed);
>>          return err;
>> }
>>
>> With the new goto, we need the same
>> if (nodes_allowed != &node_states[N_MEMORY]) before NODEMASK_FREE().
>>
>> Sorry, I missed this in previous versions.
>
> Oh right, I'm really sorry I missed that, thank you for noticing.
>

