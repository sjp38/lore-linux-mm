Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8298BC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:30:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36BAB20840
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36BAB20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD9578E0004; Wed,  6 Mar 2019 13:30:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A624E8E0002; Wed,  6 Mar 2019 13:30:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 929CE8E0004; Wed,  6 Mar 2019 13:30:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62CE08E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:30:27 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id x63so10702927qka.5
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:30:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=fIYX9OmpxqLC20eq6FnsSHIwBahfXx81gwsq9Yh5MaE=;
        b=PntJD0zaRrG7deUNRfVINN+PEWqS3wGQd1AkhfUM+1cro1oammhif+vr678WLXR/tQ
         wi6J3yRPmo0RmQgICxCK9hLOuZ+8TKD3yvq1btb4b3cOtEZMlsLQcItks+lh9QESbC/y
         PdNtXQ43YaY4psScZSJxox7uVH39wJGv2ZBdEAu+Jqgkz4nzxX6peNIfDdzaxLAx1wi+
         Uy4bfHzRYCm5kUmCbKcqJhYhkXgjIbSfGI+0/82leiTXyFO/oo4NxuuxUgXI0ypJuNPL
         WzBZFxRRldooWxcJQ2jcq8ZiAnvOw6FhIi6cn56ykEL/XHceKShWJsIzDOi+4hC0OYw8
         Sjlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXrTb2KKVuTpK3AyZK948ZYPFTObTCh5P2JLXCVSw7vAlCq3Aj6
	LH/s1ujHAPF31gTdRW3yH0oDlmKK5q+d8QTEkW5hUBKpaht/k7aDZrtBT9lOBjkfl0yhr6SwvOo
	3WXTDokvcFi3rceyP4EJ8ld7c4FNewdOI9BmgJvhE+ubZ+oYfnKSej0UgxN+llQwP5Q==
X-Received: by 2002:a37:a7ca:: with SMTP id q193mr6895511qke.102.1551897027116;
        Wed, 06 Mar 2019 10:30:27 -0800 (PST)
X-Google-Smtp-Source: APXvYqyajfar9CRe2Xcwp11uF6XzjH22DWqAGf93B3lkB+01Wx7fMnyHQqcdCw0ITLKdYFFUPUqK
X-Received: by 2002:a37:a7ca:: with SMTP id q193mr6895453qke.102.1551897026129;
        Wed, 06 Mar 2019 10:30:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897026; cv=none;
        d=google.com; s=arc-20160816;
        b=ibqXiJwN+OyQfI7EM4FSxgpLoQSHDWd2emzM/7IQ2p3RcqavqYXYHG2LZiUJm2B8NE
         D+PYJUPnnIFiANMGGmwtbYh3UR4mEXKDlijnH47cGcKbPaH6B+8S4sceIGixcOQRao/S
         3X+rfHRSSyR4aiPsMgxJxOuV1RIJv9N5q3MVZAHecFWx1fwaqssn4zkC6zpDRD6MRY/T
         ySimTuhhmDicDqV0qeAe6DV1iinlnejV73srpW4UqPXf1Uw4I/8M9FGl8/xIe1VSIjBt
         W0oEQUq4erglGooeEAerCX+kn87oPb47ldU4micNIEAhAd8xIrfAC27RaWVv3tIfNEaP
         I13Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=fIYX9OmpxqLC20eq6FnsSHIwBahfXx81gwsq9Yh5MaE=;
        b=yfIInEMilc+c1qzDD00w8ueCnm3El/6UESYUcMyPVnsn272AxcW475O+wbfGhdnn2/
         86niryF3XadWFyBzmje1u2iWTFfG5sRtEPzSiSk4FZMzvMLkmz6TRraYG1Hb3dUVY2c6
         1GV8H9mtdrU3N7UaKXh543FA2pw/7Zzi4Ul7GBt6TcQJFSIQZOExhqw3VwEd5QMX9GYa
         VH0A97aE/RIdoMcuxBK5r4AxiGsu6srUltGIHG8yrFr6kwQq3GN+Q+D7613ABArWGfn2
         fV0ARYEEnbPWx6LvdyIGfKjO+BO3FeHzdPYg/3pRA8eJzYRVSK+3MIM1stndwim78h0n
         HLCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m39si1414217qta.117.2019.03.06.10.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 10:30:26 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3B3F666997;
	Wed,  6 Mar 2019 18:30:25 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9B75318E3F;
	Wed,  6 Mar 2019 18:30:15 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
Organization: Red Hat Inc,
Message-ID: <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
Date: Wed, 6 Mar 2019 13:30:14 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190306130955-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xHjQbFXLnS08psK94Kg6ph6iXR74gEdrn"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 06 Mar 2019 18:30:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xHjQbFXLnS08psK94Kg6ph6iXR74gEdrn
Content-Type: multipart/mixed; boundary="Gh4ItdDszVTLb9zJu98nTqlKBPzKrYx6H";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Message-ID: <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--Gh4ItdDszVTLb9zJu98nTqlKBPzKrYx6H
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrote:
>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
>>>> The following patch-set proposes an efficient mechanism for handing =
freed memory between the guest and the host. It enables the guests with n=
o page cache to rapidly free and reclaims memory to and from the host res=
pectively.
>>>>
>>>> Benefit:
>>>> With this patch-series, in our test-case, executed on a single syste=
m and single NUMA node with 15GB memory, we were able to successfully lau=
nch 5 guests(each with 5 GB memory) when page hinting was enabled and 3 w=
ithout it. (Detailed explanation of the test procedure is provided at the=
 bottom under Test - 1).
>>>>
>>>> Changelog in v9:
>>>> 	* Guest free page hinting hook is now invoked after a page has been=
 merged in the buddy.
>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(cur=
rently defined as MAX_ORDER - 1) are captured.
>>>> 	* Removed kthread which was earlier used to perform the scanning, i=
solation & reporting of free pages.
>>>> 	* Pages, captured in the per cpu array are sorted based on the zone=
 numbers. This is to avoid redundancy of acquiring zone locks.
>>>>         * Dynamically allocated space is used to hold the isolated g=
uest free pages.
>>>>         * All the pages are reported asynchronously to the host via =
virtio driver.
>>>>         * Pages are returned back to the guest buddy free list only =
when the host response is received.
>>>>
>>>> Pending items:
>>>>         * Make sure that the guest free page hinting's current imple=
mentation doesn't break hugepages or device assigned guests.
>>>> 	* Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support. =
(It is currently missing)
>>>>         * Compare reporting free pages via vring with vhost.
>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>> 	* Analyze overall performance impact due to guest free page hinting=
=2E
>>>> 	* Come up with proper/traceable error-message/logs.
>>>>
>>>> Tests:
>>>> 1. Use-case - Number of guests we can launch
>>>>
>>>> 	NUMA Nodes =3D 1 with 15 GB memory
>>>> 	Guest Memory =3D 5 GB
>>>> 	Number of cores in guest =3D 1
>>>> 	Workload =3D test allocation program allocates 4GB memory, touches =
it via memset and exits.
>>>> 	Procedure =3D
>>>> 	The first guest is launched and once its console is up, the test al=
location program is executed with 4 GB memory request (Due to this the gu=
est occupies almost 4-5 GB of memory in the host in a system without page=
 hinting). Once this program exits at that time another guest is launched=
 in the host and the same process is followed. We continue launching the =
guests until a guest gets killed due to low memory condition in the host.=

>>>>
>>>> 	Results:
>>>> 	Without hinting =3D 3
>>>> 	With hinting =3D 5
>>>>
>>>> 2. Hackbench
>>>> 	Guest Memory =3D 5 GB=20
>>>> 	Number of cores =3D 4
>>>> 	Number of tasks		Time with Hinting	Time without Hinting
>>>> 	4000			19.540			17.818
>>>>
>>> How about memhog btw?
>>> Alex reported:
>>>
>>> 	My testing up till now has consisted of setting up 4 8GB VMs on a sy=
stem
>>> 	with 32GB of memory and 4GB of swap. To stress the memory on the sys=
tem I
>>> 	would run "memhog 8G" sequentially on each of the guests and observe=
 how
>>> 	long it took to complete the run. The observed behavior is that on t=
he
>>> 	systems with these patches applied in both the guest and on the host=
 I was
>>> 	able to complete the test with a time of 5 to 7 seconds per guest. O=
n a
>>> 	system without these patches the time ranged from 7 to 49 seconds pe=
r
>>> 	guest. I am assuming the variability is due to time being spent writ=
ing
>>> 	pages out to disk in order to free up space for the guest.
>>>
>> Here are the results:
>>
>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with=

>> total memory of 15GB and no swap. In each of the guest, memhog is run
>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
>> using Free command.
>>
>> Without Hinting:
>> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 Time of execution=C2=A0=C2=A0=C2=A0 Host used memory
>> Guest 1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 45 seconds=C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 5.4 GB
>> Guest 2:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 45 seconds=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 10 GB
>> Guest 3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 1=C2=A0 minute=C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 15 GB
>>
>> With Hinting:
>> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0=
 Time of execution =C2=A0=C2=A0=C2=A0 Host used memory
>> Guest 1:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 49 seconds=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 2.4 GB
>> Guest 2:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 40 seconds=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 4.3 GB
>> Guest 3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 50 seconds=C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 6.3 GB
> OK so no improvement.
If we are looking in terms of memory we are getting back from the guest,
then there is an improvement. However, if we are looking at the
improvement in terms of time of execution of memhog then yes there is non=
e.
>  OTOH Alex's patches cut time down to 5-7 seconds
> which seems better.=20
I haven't investigated memhog as such so cannot comment on what exactly
it does and why there was a time difference. I can take a look at it.
> Want to try testing Alex's patches for comparison?
Somehow I am not in a favor of doing a hypercall on every page (with
huge TLB order/MAX_ORDER -1) as I think it will be costly.
I can try using Alex's host side logic instead of virtio.
Let me know what you think?
>
--=20
Regards
Nitesh


--Gh4ItdDszVTLb9zJu98nTqlKBPzKrYx6H--

--xHjQbFXLnS08psK94Kg6ph6iXR74gEdrn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyAEbYACgkQo4ZA3AYy
ozmsKQ//VF+74g1jkdSVQK75bfLGAqPYy9geeG07EhZ6PmPy8QXvPLLswl5R4hKz
9Y4Uxf/53xyYxiwGRfccHTd2pA6c8rhF+yZvqRyQobFRmGCVwoL8YuusD1dBf3Gn
eCEhoP+mDScQ/fmhmbvsWd49RtMVBayqkK6slghn29nsla6dEVqpEWPeBX3g+pFe
7s4tc6WY/mX1KTwMrIhkyEqQCATPlmFOAxLLzTk4WvlgxxBBRyxvThwovhE2xrLw
I2iRjw6KtNVfacnNk9sFVHJhyhmOUKIZQwIqCl4e6JFtuV29odl5n/9RGjsWh6Ur
mOG5UJKTA6QhChtWn/8IfmGQUOnEkiRH+svH4q4mh9+g8DlnLdoWrKvn9iUnlb0J
tpbYnhnFMGg/90tjJHvHcEoFgaqCjs8HKGg5D6NavKVniK07RCYjFoa3hWJZH+S2
i+9W0oB4OhWXh4JIWNBfq8bA5anS8YkewNMI/oHeioCZa3Gb+++FMvCVoOZ1r8bg
EbBKcEy61FmP/F7wWsSP9TrjqHMbOqTX9obvyjnN84ZKKcmKywo5E0R2EzuEWduO
xo+9yOkTUQg4GVcTnAqZxyqCu2ovEGhfmZrPFerRyAtkRTYxYcj+kJRHdEgmea/A
1GIiUOg7DFu/OlgOvtbbbZl1HqsDXODU6emmYXxUeXvprfmW+YA=
=8G1M
-----END PGP SIGNATURE-----

--xHjQbFXLnS08psK94Kg6ph6iXR74gEdrn--

