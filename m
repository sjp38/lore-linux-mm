Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F4BC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:07:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D76D20652
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:07:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D76D20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFA168E0003; Wed,  6 Mar 2019 13:07:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAB088E0002; Wed,  6 Mar 2019 13:07:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72F28E0003; Wed,  6 Mar 2019 13:07:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB458E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:07:55 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q15so10620035qki.14
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:07:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=8SC+A5bGes6rvC1+IIh5/kbesOiJW6bttiBw9f5Y398=;
        b=WnHGD1HmkrSM0A6wS/8oEMSBC4t2nAcQoXUzolG1ke8Anm9QcE39gnxjszLEIKbniT
         0Nr2NYrH99a9wRoHB3qmmDQLJmRsF8NbHyw2tWYS5JZLN9Cf3SrdXjXPqHmepcNOnWfo
         6JcjrtUIxazqxCtRbaulXfvaxlbmYnlC7tosnOhPjH5joNLlo+nsAVQBms67oIYXs13x
         D70mP7pPcNzGShS019O2UxSubmmDbfMVmlt0QV5n8IlQKObu9N5k/HMNjIcsEBnh7px4
         lQolqEOitqKvEdIT/vTUH4vaUrG9gTwdPes8mKPPp7dCLEAF2pXEk+2+9eZ2ezQGTbQc
         8nsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXbHL7IzO/Ay9ERvERvV+5I2iV+4vs9QVq4uECzPG8b66H4UOXO
	AZ0Fh2WxGwo5/qFpBLGUKe0/px4QvQARGFNJgg73zJTNZDaB/yhvAdl2zFuYZBe6Bcxlxw4A/ds
	E/BQEGy7rurFaQ8caSBIzW/4Al2bYRo4RQm8UU09u+I7EA0uNWxW0CYzXZUT+szdpPg==
X-Received: by 2002:ac8:168b:: with SMTP id r11mr6638928qtj.387.1551895675236;
        Wed, 06 Mar 2019 10:07:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqyQgClmgnc+QP2WiUiLB0wu7ZJd9jiBIzF/FKMNOqVeR9o00+OXscoCdXGtvQZVU+M4tP+p
X-Received: by 2002:ac8:168b:: with SMTP id r11mr6638855qtj.387.1551895674272;
        Wed, 06 Mar 2019 10:07:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551895674; cv=none;
        d=google.com; s=arc-20160816;
        b=nSAOiFaO5lGwA9MA93N4mAyU2NB5uu4qNat8zNGXUhhvtmLdV0JPzHGup4PweU3YoZ
         bBzkJaxOfztLpE4HPu2xcmT+kUM6O/e+pFVcXr+CUzJOjTXNwhrbJ23i/3FBEclezR7q
         She3VldMpCZ8VKj1AOm/QoDKgF+g5pHr+HCfeTPIA6kPq36/4udXEhAH6gQjQb+3vCd7
         pcg4fY7cIErAOX8U5KTLZi2H2hy8FvfSWh7JF4NKMgYwZF5zDsXmterAFfyFBIHRZO1N
         kv9Qr2XPVcYAWHXr4juEad/+byoMrBBjJwit43UTZNoxCt4S7M+cxI7zai692twlkh4+
         jD7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=8SC+A5bGes6rvC1+IIh5/kbesOiJW6bttiBw9f5Y398=;
        b=DnnGXZ+BwVemrZoEhi+m1dMj9ju3rnMTQSFmfuzfeyRSUg1PXT1leyBlq2dQR61Khc
         AYBrlACUjjKbryapao57REF3SxI3ndD/rKhu/JsxDMwzOqFvZa4RDHT7mFmCizH20kXA
         buAJwDZDaaFVcuePwnLRp2wzZ1T/6RHXAl9y4pcmxn/QquP5nB3+lWW3siwvVFMdWFL4
         O+oKP3t5D+ofJtbjfQi8vTql4ITxzMWIRNBr4Fhq1tsSWXzUAYyCl+oaI1fEdbCn2/yJ
         3kZzTRZGfKi2RqV9/LmXRz8UL3/mpSh6KU+i4tH4SySlQ7FHXJMEz5ojBCp39nAQ691M
         TAoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l29si1350681qtb.91.2019.03.06.10.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 10:07:54 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F5683092658;
	Wed,  6 Mar 2019 18:07:53 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 91CACA4F84;
	Wed,  6 Mar 2019 18:07:51 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
Date: Wed, 6 Mar 2019 13:07:50 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190306110501-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="JxYzMsx6no2b159rO7jMVpujrTFgIS6rJ"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 06 Mar 2019 18:07:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JxYzMsx6no2b159rO7jMVpujrTFgIS6rJ
Content-Type: multipart/mixed; boundary="gsK4cdQ2SmPsmm3JcrDh3layyISQw5H9P";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Message-ID: <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190306110501-mutt-send-email-mst@kernel.org>

--gsK4cdQ2SmPsmm3JcrDh3layyISQw5H9P
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
>> The following patch-set proposes an efficient mechanism for handing fr=
eed memory between the guest and the host. It enables the guests with no =
page cache to rapidly free and reclaims memory to and from the host respe=
ctively.
>>
>> Benefit:
>> With this patch-series, in our test-case, executed on a single system =
and single NUMA node with 15GB memory, we were able to successfully launc=
h 5 guests(each with 5 GB memory) when page hinting was enabled and 3 wit=
hout it. (Detailed explanation of the test procedure is provided at the b=
ottom under Test - 1).
>>
>> Changelog in v9:
>> 	* Guest free page hinting hook is now invoked after a page has been m=
erged in the buddy.
>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(curre=
ntly defined as MAX_ORDER - 1) are captured.
>> 	* Removed kthread which was earlier used to perform the scanning, iso=
lation & reporting of free pages.
>> 	* Pages, captured in the per cpu array are sorted based on the zone n=
umbers. This is to avoid redundancy of acquiring zone locks.
>>         * Dynamically allocated space is used to hold the isolated gue=
st free pages.
>>         * All the pages are reported asynchronously to the host via vi=
rtio driver.
>>         * Pages are returned back to the guest buddy free list only wh=
en the host response is received.
>>
>> Pending items:
>>         * Make sure that the guest free page hinting's current impleme=
ntation doesn't break hugepages or device assigned guests.
>> 	* Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support. (I=
t is currently missing)
>>         * Compare reporting free pages via vring with vhost.
>>         * Decide between MADV_DONTNEED and MADV_FREE.
>> 	* Analyze overall performance impact due to guest free page hinting.
>> 	* Come up with proper/traceable error-message/logs.
>>
>> Tests:
>> 1. Use-case - Number of guests we can launch
>>
>> 	NUMA Nodes =3D 1 with 15 GB memory
>> 	Guest Memory =3D 5 GB
>> 	Number of cores in guest =3D 1
>> 	Workload =3D test allocation program allocates 4GB memory, touches it=
 via memset and exits.
>> 	Procedure =3D
>> 	The first guest is launched and once its console is up, the test allo=
cation program is executed with 4 GB memory request (Due to this the gues=
t occupies almost 4-5 GB of memory in the host in a system without page h=
inting). Once this program exits at that time another guest is launched i=
n the host and the same process is followed. We continue launching the gu=
ests until a guest gets killed due to low memory condition in the host.
>>
>> 	Results:
>> 	Without hinting =3D 3
>> 	With hinting =3D 5
>>
>> 2. Hackbench
>> 	Guest Memory =3D 5 GB=20
>> 	Number of cores =3D 4
>> 	Number of tasks		Time with Hinting	Time without Hinting
>> 	4000			19.540			17.818
>>
> How about memhog btw?
> Alex reported:
>
> 	My testing up till now has consisted of setting up 4 8GB VMs on a syst=
em
> 	with 32GB of memory and 4GB of swap. To stress the memory on the syste=
m I
> 	would run "memhog 8G" sequentially on each of the guests and observe h=
ow
> 	long it took to complete the run. The observed behavior is that on the=

> 	systems with these patches applied in both the guest and on the host I=
 was
> 	able to complete the test with a time of 5 to 7 seconds per guest. On =
a
> 	system without these patches the time ranged from 7 to 49 seconds per
> 	guest. I am assuming the variability is due to time being spent writin=
g
> 	pages out to disk in order to free up space for the guest.
>
Here are the results:

Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
total memory of 15GB and no swap. In each of the guest, memhog is run
with 5GB. Post-execution of memhog, Host memory usage is monitored by
using Free command.

Without Hinting:
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0 Time of execution=C2=A0=C2=A0=C2=A0 Host used memory
Guest 1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 45 seconds=C2=A0=C2=A0=C2=A0=
 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 5.4 GB
Guest 2:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 45 seconds=C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 10 GB
Guest 3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 1=C2=A0 minute=C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 15 GB

With Hinting:
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 Ti=
me of execution =C2=A0=C2=A0=C2=A0 Host used memory
Guest 1:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 49 seconds=C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 2.4 GB
Guest 2:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 40 seconds=C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 4.3 GB
Guest 3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 50 seconds=C2=A0=C2=A0=C2=A0=
 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 6.3 GB

--=20
Regards
Nitesh


--gsK4cdQ2SmPsmm3JcrDh3layyISQw5H9P--

--JxYzMsx6no2b159rO7jMVpujrTFgIS6rJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyADHYACgkQo4ZA3AYy
ozkwHxAAwWuIcoLYbXpaVTgkAQjS58cpp8y0fUeNTTCp9lLte05X7trXtbU84Ilm
BGrPLyzl11WCPjC8SQ9UjbDq+1SbGTmxMNzEOKumXWbfNQk01B/1LK6NKdLi9Y+f
Cu7Q7/p9wiBe1lLVPBsl2E6MgP+TDUkT1EVxG78d7XcCKeOQjB/TobGMRfrohyEo
8CaWFy5q6Pm3+vBXbfdec5hdSJwd6Sc8g1M0Axw9RWvEqaVtuhF1Z7Henm3BvU2R
89oNUZmGM6rHmdhKKqVcrV23WNLvSOobLwZHexydU/pHJfYtKzt8EBr+SMkRXUgK
aKVuoZIMJPfJBtyE0CzSp33b738A9yatb6m0KOu0kKrwJ8YzgPI1F1T/Bwo0LxZ0
MRn3Qpm0J9xOOGeDRW+rPDVvWhwVX3/CnkcCTUFjzLV213kOwVt5kOmeg9oBw5Ui
iyw+GE8u2W/mK+hPiZKPbH4TIS7TPddftyNO2OdZLM7jccJcXhkEHYPF446lV8c7
N9iCpGxEUXjIBDvmZX0mtBUkX0eIT838HgphfyOsDzsPtEcd2IkfxMUyUL8Qtj53
0Xt277DRWmw3euqjCsqTm1IfSO7zTB6ljxqK9YPFBSUziYnDEDUbIwBoDg08aCXD
uBwnS9/DqS40HLXFUnDodu/c+ZaDr1jcuLh/clu8wzLLlOpNSFA=
=J3yz
-----END PGP SIGNATURE-----

--JxYzMsx6no2b159rO7jMVpujrTFgIS6rJ--

