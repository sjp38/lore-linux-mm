Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABB76C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EA052080C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=apple.com header.i=@apple.com header.b="EZSttxZp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EA052080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=apple.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0A8B6B0005; Thu,  1 Aug 2019 18:28:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB9426B0006; Thu,  1 Aug 2019 18:28:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C9B6B0008; Thu,  1 Aug 2019 18:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA766B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:28:39 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id 132so80861247iou.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:message-id
         :mime-version:subject:date:in-reply-to:cc:to:references;
        bh=lhPcKlydFtoNsMUs5DpRPTZekMuUt3luMq+1FU+xdtw=;
        b=PkVYuaf5GQX603RN41GNr3YpNSjCzQu/qpWSDR5UjZtr6DPPOkbFkiVCcAAOQArD7n
         r8V0WA3NCMR/IXMJEWBHnRwT4hd5dSc+FWzlWAFs1Vb63deIQ8FmlzrtiSA/UxSxJIJt
         YIsdz91MbnrNiUx+Y3gITxMyktEYi7kkwPcWSJ/DHEzVygW0lK7tLpS+cS41dBYXGp3H
         5IHltLaQsa3hkbT+c/RC4jizxkyZODF7Rn7H+uzIqvlrMXLwvTiDYfeIrnaJIsEfT0ZY
         XJ0PD+/6U6tXUVc4EqDRuaWmCUhBiNqstxRMp9sO76YwSZWDB3kuFQAO8+i0hK8zmnfQ
         VIqA==
X-Gm-Message-State: APjAAAW2avuksXQMTFdAFDQwTXOlPw5m2LQziG5NejUNTnL5M4Y9cKaP
	FjklXBtrlpf/pkj073UfHp7onZ9W9YqMd6n2SILDroTg8EDluz33tmS8otJfoJRW0QA1dNefhtM
	qlTopwpJqMlUIBiL8gzV3hETtBpDLR4lrXzoi4J+j4tWOXNROFQJyVfvxefcQV+cOQQ==
X-Received: by 2002:a5d:9e49:: with SMTP id i9mr54062200ioi.290.1564698518851;
        Thu, 01 Aug 2019 15:28:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj+f58He1Wxni4xIFI/0OxYdnj20UFITwDFAPy7806kBJo3U8SY2vC8mtBKhxu/49ZVoF0
X-Received: by 2002:a5d:9e49:: with SMTP id i9mr54062117ioi.290.1564698517735;
        Thu, 01 Aug 2019 15:28:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564698517; cv=none;
        d=google.com; s=arc-20160816;
        b=Tf2DPv3RCemAspEc0Ea0y4Spo2JrLvRktg0M/UMJDeFUbxNahcOzXEPZUZpRDRTmNv
         hvl8SaXy5jCpGyOp9M7q4SypYAPH0jAmScPPY5sT3XHl0RHNFnvl3xVdyx4qdTv/yhHK
         7HMjLMmGrGXhhh0BnWyl0cR6y46euqEj+wy3iOiXVtzph3ItEoz3zxagQT8CfZB6ODE3
         wmc4e1p839sN2//IKB5JywVz0QyY97Rw6wXtsOLsPoLyuwlToG1i8UWd+SIwhJ5pmOmD
         S1OStxpCXlNwAEkjD04Gu2NSQIamy1zyA6ToWXmJY+cluhZugxKy3p06wnGISm+ZohZp
         79Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
         :from:sender:dkim-signature;
        bh=lhPcKlydFtoNsMUs5DpRPTZekMuUt3luMq+1FU+xdtw=;
        b=W75BCLiF2zoJXKGWBF1ykCZC1SqBKjWgi+UxJFynNHSQZnUbriaml+OS0MQWhTyEb/
         MvCIdVmtytQEqkxxHYn4gZEK9i3Y2/HxFSMQzX2qgTa51wDJqEZO6jqUbr0AW2GmoxhR
         F4EVZQfyGJTB6u5aLPjWR0esr/6rsN4UM7kVp56F9Y3LrjdqZRuo6eQXb1omMnSeMkew
         KX4uJz9eCLUlfvqZMXgOstgTQrkD9Q1q02ABbGR+4BQ5bQ06FKgjaHQORyJo0bp/IWtE
         pR+eqeo2QTfwymXI8qRY0XfjZGwbDmK3mA2JDTHhxaZi1bKEWNhTZwS/fbLID/ABajka
         HE2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b=EZSttxZp;
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.171.2.60 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from ma1-aaemail-dr-lapp01.apple.com (ma1-aaemail-dr-lapp01.apple.com. [17.171.2.60])
        by mx.google.com with ESMTPS id e8si88095890ios.150.2019.08.01.15.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:28:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of msharbiani@apple.com designates 17.171.2.60 as permitted sender) client-ip=17.171.2.60;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b=EZSttxZp;
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.171.2.60 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from pps.filterd (ma1-aaemail-dr-lapp01.apple.com [127.0.0.1])
	by ma1-aaemail-dr-lapp01.apple.com (8.16.0.27/8.16.0.27) with SMTP id x71MRHPP019848;
	Thu, 1 Aug 2019 15:28:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=apple.com; h=sender : from :
 message-id : content-type : mime-version : subject : date : in-reply-to :
 cc : to : references; s=20180706;
 bh=lhPcKlydFtoNsMUs5DpRPTZekMuUt3luMq+1FU+xdtw=;
 b=EZSttxZplCfK4Z4tB5QdIYRSyV05WjfClrmdN05KnSE1vv7oiJjJSdnmHm9KHoV453od
 zKjwWlEPh5wRzlG2A+sPDlAHJm3nbx9trUFeC1EAVvgkEEwSh8agg3K6lM59tEuoLaxO
 n6/BPx7qxXBpbQyoz9mqpmxkagkK8z6F6iN/9zfyt+vpfOEdJcErC8xNcZU4HiX8jyhX
 aNI1oTM7qVSwyel8wfdRtHll+4JFkOHgxjvh0LXbDzF7/eL/ipxME7blAFKaYG9l5vqI
 1YcwPNF/ZQdSsjbHb9n0nlkxnPATFVQGSIeJR49uvYHAnTlQr+0V1KzyMVPGK+FMNqSI QQ== 
Received: from mr2-mtap-s03.rno.apple.com (mr2-mtap-s03.rno.apple.com [17.179.226.135])
	by ma1-aaemail-dr-lapp01.apple.com with ESMTP id 2u2tgeebsj-9
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO);
	Thu, 01 Aug 2019 15:28:31 -0700
Received: from nwk-mmpp-sz09.apple.com
 (nwk-mmpp-sz09.apple.com [17.128.115.80]) by mr2-mtap-s03.rno.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPS id <0PVK00JFWX3GW520@mr2-mtap-s03.rno.apple.com>; Thu,
 01 Aug 2019 15:28:31 -0700 (PDT)
Received: from process_milters-daemon.nwk-mmpp-sz09.apple.com by
 nwk-mmpp-sz09.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) id <0PVK00400X2ZFA00@nwk-mmpp-sz09.apple.com>; Thu,
 01 Aug 2019 15:28:29 -0700 (PDT)
X-Va-A: 
X-Va-T-CD: 7e5a4a8cbd5d1b3a9de5dc9e235184f7
X-Va-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-Va-R-CD: 1835f3c54d533384876758843bc94ede
X-Va-CD: 0
X-Va-ID: 06242704-8e8a-4206-93cd-44961dba0e17
X-V-A: 
X-V-T-CD: 3292cb8df71769077a8e6c728895331c
X-V-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-V-R-CD: 1835f3c54d533384876758843bc94ede
X-V-CD: 0
X-V-ID: 9772020c-dc99-4e56-9d39-dec04d131d68
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,,
 definitions=2019-08-01_09:,, signatures=0
Received: from iceman.apple.com (iceman.apple.com [17.228.212.91])
 by nwk-mmpp-sz09.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPSA id <0PVK00MP4X0QUQ30@nwk-mmpp-sz09.apple.com>; Thu,
 01 Aug 2019 15:26:51 -0700 (PDT)
From: Masoud Sharbiani <msharbiani@apple.com>
Message-id: <E9FD47D4-C44A-4220-8631-01F7E716531D@apple.com>
Content-type: multipart/signed;
 boundary="Apple-Mail=_4F8822D2-B7E4-4AD0-9773-8558C9BF4E33";
 protocol="application/pkcs7-signature"; micalg=sha-256
MIME-version: 1.0 (Mac OS X Mail 13.0 \(3570.1\))
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Date: Thu, 01 Aug 2019 15:26:50 -0700
In-reply-to: <20190801181952.GA8425@kroah.com>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
        linux-mm@kvack.org, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190801181952.GA8425@kroah.com>
X-Mailer: Apple Mail (2.3570.1)
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_09:,,
 signatures=0
X-Proofpoint-AD-Result: pass
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail=_4F8822D2-B7E4-4AD0-9773-8558C9BF4E33
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_EDBF6EA1-3636-447A-9165-8D973FD3B647"


--Apple-Mail=_EDBF6EA1-3636-447A-9165-8D973FD3B647
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

Allow me to issue a correction:=20
Running this test on linux master =
<629f8205a6cc63d2e8e30956bad958a3507d018f> correctly terminates the =
leaker app with OOM.=20
However, running it a second time (after removing the memory cgroup, and =
allowing the test script to run it again), causes this:

 kernel:watchdog: BUG: soft lockup - CPU#7 stuck for 22s! [leaker1:7193]


[  202.511024] CPU: 7 PID: 7193 Comm: leaker1 Not tainted 5.3.0-rc2+ #8
[  202.517378] Hardware name: <redacted>
[  202.525554] RIP: 0010:lruvec_lru_size+0x49/0xf0
[  202.530085] Code: 41 89 ed b8 ff ff ff ff 45 31 f6 49 c1 e5 03 eb 19 =
48 63 d0 4c 89 e9 48 8b 14 d5 20 b7 11 b5 48 03 8b 88 00 00 00 4c 03 34 =
11 <48> c7 c6 80 c5 40 b5 89 c7 e8 29 a7 6f 00 3b 05 57 9d 24 01 72 d1
[  202.548831] RSP: 0018:ffffa7c5480df620 EFLAGS: 00000246 ORIG_RAX: =
ffffffffffffff13
[  202.556398] RAX: 0000000000000000 RBX: ffff8f5b7a1af800 RCX: =
00003859bfa03bc0
[  202.563528] RDX: ffff8f5b7f800000 RSI: 0000000000000018 RDI: =
ffffffffb540c580
[  202.570662] RBP: 0000000000000001 R08: 0000000000000000 R09: =
0000000000000004
[  202.577795] R10: ffff8f5b62548000 R11: 0000000000000000 R12: =
0000000000000004
[  202.584928] R13: 0000000000000008 R14: 0000000000000000 R15: =
0000000000000000
[  202.592063] FS:  00007ff73d835740(0000) GS:ffff8f6b7f840000(0000) =
knlGS:0000000000000000
[  202.600149] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  202.605895] CR2: 00007f1b1c00e428 CR3: 0000001021d56006 CR4: =
00000000001606e0
[  202.613026] Call Trace:
[  202.615475]  shrink_node_memcg+0xdb/0x7a0
[  202.619488]  ? shrink_slab+0x266/0x2a0
[  202.623242]  ? mem_cgroup_iter+0x10a/0x2c0
[  202.627337]  shrink_node+0xdd/0x4c0
[  202.630831]  do_try_to_free_pages+0xea/0x3c0
[  202.635104]  try_to_free_mem_cgroup_pages+0xf5/0x1e0
[  202.640068]  try_charge+0x279/0x7a0
[  202.643565]  mem_cgroup_try_charge+0x51/0x1a0
[  202.647925]  __add_to_page_cache_locked+0x19f/0x330
[  202.652800]  ? __mod_lruvec_state+0x40/0xe0
[  202.656987]  ? scan_shadow_nodes+0x30/0x30
[  202.661086]  add_to_page_cache_lru+0x49/0xd0
[  202.665361]  iomap_readpages_actor+0xea/0x230
[  202.669718]  ? iomap_migrate_page+0xe0/0xe0
[  202.673906]  iomap_apply+0xb8/0x150
[  202.677398]  iomap_readpages+0xa7/0x1a0
[  202.681237]  ? iomap_migrate_page+0xe0/0xe0
[  202.685424]  read_pages+0x68/0x190
[  202.688829]  __do_page_cache_readahead+0x19c/0x1b0
[  202.693622]  ondemand_readahead+0x168/0x2a0
[  202.697808]  filemap_fault+0x32d/0x830
[  202.701562]  ? __mod_lruvec_state+0x40/0xe0
[  202.705747]  ? page_remove_rmap+0xcf/0x150
[  202.709846]  ? alloc_set_pte+0x240/0x2c0
[  202.713775]  __xfs_filemap_fault+0x71/0x1c0
[  202.717963]  __do_fault+0x38/0xb0
[  202.721280]  __handle_mm_fault+0x73f/0x1080
[  202.725467]  ? __switch_to_asm+0x34/0x70
[  202.729390]  ? __switch_to_asm+0x40/0x70
[  202.733318]  handle_mm_fault+0xce/0x1f0
[  202.737158]  __do_page_fault+0x231/0x480
[  202.741083]  page_fault+0x2f/0x40
[  202.744404] RIP: 0033:0x400c20
[  202.747461] Code: 45 c8 48 89 c6 bf 32 0e 40 00 b8 00 00 00 00 e8 76 =
fb ff ff c7 45 ec 00 00 00 00 eb 36 8b 45 ec 48 63 d0 48 8b 45 c8 48 01 =
d0 <0f> b6 00 0f be c0 01 45 e4 8b 45 ec 25 ff 0f 00 00 85 c0 75 10 8b
[  202.766208] RSP: 002b:00007ffde95ae460 EFLAGS: 00010206
[  202.771432] RAX: 00007ff71e855000 RBX: 0000000000000000 RCX: =
000000000000001a
[  202.778558] RDX: 0000000001dfd000 RSI: 000000007fffffe5 RDI: =
0000000000000000
[  202.785692] RBP: 00007ffde95af4b0 R08: 0000000000000000 R09: =
00007ff73d2a520d
[  202.792823] R10: 0000000000000002 R11: 0000000000000246 R12: =
0000000000400850
[  202.799949] R13: 00007ffde95af590 R14: 0000000000000000 R15: =
0000000000000000


Further tests show that this also happens if one waits long enough on  =
5.3-rc1 as well.
So I don=E2=80=99t think we have a fix in tree yet.=20

Cheers,
Masoud


> On Aug 1, 2019, at 11:19 AM, Greg KH <gregkh@linuxfoundation.org> =
wrote:
>=20
> On Thu, Aug 01, 2019 at 11:04:14AM -0700, Masoud Sharbiani wrote:
>> Hey folks,
>> I=E2=80=99ve come across an issue that affects most of 4.19, 4.20 and =
5.2 linux-stable kernels that has only been fixed in 5.3-rc1.
>> It was introduced by
>>=20
>> 29ef680 memcg, oom: move out_of_memory back to the charge path=20
>>=20
>> The gist of it is that if you have a memory control group for a =
process that repeatedly maps all of the pages of a file with  repeated =
calls to:
>>=20
>>   mmap(NULL, pages * PAGE_SIZE, PROT_WRITE|PROT_READ, =
MAP_FILE|MAP_PRIVATE, fd, 0)
>>=20
>> The memory cg eventually runs out of memory, as it should. However,
>> prior to the 29ef680 commit, it would kill the running process with
>> OOM; After that commit ( and until 5.3-rc1; Haven=E2=80=99t =
pinpointed the
>> exact commit in between 5.2.0 and 5.3-rc1) the offending process goes
>> into %100 CPU usage, and doesn=E2=80=99t die (prior behavior) or fail =
the mmap
>> call (which is what happens if one runs the test program with a low
>> ulimit -v value).
>>=20
>> Any ideas on how to chase this down further?
>=20
> Finding the exact patch that fixes this would be great, as then I can
> add it to the 4.19 and 5.2 stable kernels (4.20 is long end-of-life, =
no
> idea why you are messing with that one...)
>=20
> thanks,
>=20
> greg k-h


--Apple-Mail=_EDBF6EA1-3636-447A-9165-8D973FD3B647
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">Allow=
 me to issue a correction:&nbsp;<div class=3D"">Running this test on =
linux master &lt;629f8205a6cc63d2e8e30956bad958a3507d018f&gt; correctly =
terminates the leaker app with OOM.&nbsp;</div><div class=3D"">However, =
running it a second time (after removing the memory cgroup, and allowing =
the test script to run it again), causes this:</div><div class=3D""><br =
class=3D""></div><div class=3D"">&nbsp;kernel:watchdog: BUG: soft lockup =
- CPU#7 stuck for 22s! [leaker1:7193]</div><div class=3D""><br =
class=3D""></div><div class=3D""><br class=3D""></div><div class=3D""><div=
 class=3D"">[ &nbsp;202.511024] CPU: 7 PID: 7193 Comm: leaker1 Not =
tainted 5.3.0-rc2+ #8</div><div class=3D"">[ &nbsp;202.517378] Hardware =
name: &lt;redacted&gt;</div><div class=3D"">[ &nbsp;202.525554] RIP: =
0010:lruvec_lru_size+0x49/0xf0</div><div class=3D"">[ &nbsp;202.530085] =
Code: 41 89 ed b8 ff ff ff ff 45 31 f6 49 c1 e5 03 eb 19 48 63 d0 4c 89 =
e9 48 8b 14 d5 20 b7 11 b5 48 03 8b 88 00 00 00 4c 03 34 11 &lt;48&gt; =
c7 c6 80 c5 40 b5 89 c7 e8 29 a7 6f 00 3b 05 57 9d 24 01 72 d1</div><div =
class=3D"">[ &nbsp;202.548831] RSP: 0018:ffffa7c5480df620 EFLAGS: =
00000246 ORIG_RAX: ffffffffffffff13</div><div class=3D"">[ =
&nbsp;202.556398] RAX: 0000000000000000 RBX: ffff8f5b7a1af800 RCX: =
00003859bfa03bc0</div><div class=3D"">[ &nbsp;202.563528] RDX: =
ffff8f5b7f800000 RSI: 0000000000000018 RDI: ffffffffb540c580</div><div =
class=3D"">[ &nbsp;202.570662] RBP: 0000000000000001 R08: =
0000000000000000 R09: 0000000000000004</div><div class=3D"">[ =
&nbsp;202.577795] R10: ffff8f5b62548000 R11: 0000000000000000 R12: =
0000000000000004</div><div class=3D"">[ &nbsp;202.584928] R13: =
0000000000000008 R14: 0000000000000000 R15: 0000000000000000</div><div =
class=3D"">[ &nbsp;202.592063] FS: &nbsp;00007ff73d835740(0000) =
GS:ffff8f6b7f840000(0000) knlGS:0000000000000000</div><div class=3D"">[ =
&nbsp;202.600149] CS: &nbsp;0010 DS: 0000 ES: 0000 CR0: =
0000000080050033</div><div class=3D"">[ &nbsp;202.605895] CR2: =
00007f1b1c00e428 CR3: 0000001021d56006 CR4: 00000000001606e0</div><div =
class=3D"">[ &nbsp;202.613026] Call Trace:</div><div class=3D"">[ =
&nbsp;202.615475] &nbsp;shrink_node_memcg+0xdb/0x7a0</div><div =
class=3D"">[ &nbsp;202.619488] &nbsp;? shrink_slab+0x266/0x2a0</div><div =
class=3D"">[ &nbsp;202.623242] &nbsp;? =
mem_cgroup_iter+0x10a/0x2c0</div><div class=3D"">[ &nbsp;202.627337] =
&nbsp;shrink_node+0xdd/0x4c0</div><div class=3D"">[ &nbsp;202.630831] =
&nbsp;do_try_to_free_pages+0xea/0x3c0</div><div class=3D"">[ =
&nbsp;202.635104] =
&nbsp;try_to_free_mem_cgroup_pages+0xf5/0x1e0</div><div class=3D"">[ =
&nbsp;202.640068] &nbsp;try_charge+0x279/0x7a0</div><div class=3D"">[ =
&nbsp;202.643565] &nbsp;mem_cgroup_try_charge+0x51/0x1a0</div><div =
class=3D"">[ &nbsp;202.647925] =
&nbsp;__add_to_page_cache_locked+0x19f/0x330</div><div class=3D"">[ =
&nbsp;202.652800] &nbsp;? __mod_lruvec_state+0x40/0xe0</div><div =
class=3D"">[ &nbsp;202.656987] &nbsp;? =
scan_shadow_nodes+0x30/0x30</div><div class=3D"">[ &nbsp;202.661086] =
&nbsp;add_to_page_cache_lru+0x49/0xd0</div><div class=3D"">[ =
&nbsp;202.665361] &nbsp;iomap_readpages_actor+0xea/0x230</div><div =
class=3D"">[ &nbsp;202.669718] &nbsp;? =
iomap_migrate_page+0xe0/0xe0</div><div class=3D"">[ &nbsp;202.673906] =
&nbsp;iomap_apply+0xb8/0x150</div><div class=3D"">[ &nbsp;202.677398] =
&nbsp;iomap_readpages+0xa7/0x1a0</div><div class=3D"">[ =
&nbsp;202.681237] &nbsp;? iomap_migrate_page+0xe0/0xe0</div><div =
class=3D"">[ &nbsp;202.685424] &nbsp;read_pages+0x68/0x190</div><div =
class=3D"">[ &nbsp;202.688829] =
&nbsp;__do_page_cache_readahead+0x19c/0x1b0</div><div class=3D"">[ =
&nbsp;202.693622] &nbsp;ondemand_readahead+0x168/0x2a0</div><div =
class=3D"">[ &nbsp;202.697808] &nbsp;filemap_fault+0x32d/0x830</div><div =
class=3D"">[ &nbsp;202.701562] &nbsp;? =
__mod_lruvec_state+0x40/0xe0</div><div class=3D"">[ &nbsp;202.705747] =
&nbsp;? page_remove_rmap+0xcf/0x150</div><div class=3D"">[ =
&nbsp;202.709846] &nbsp;? alloc_set_pte+0x240/0x2c0</div><div class=3D"">[=
 &nbsp;202.713775] &nbsp;__xfs_filemap_fault+0x71/0x1c0</div><div =
class=3D"">[ &nbsp;202.717963] &nbsp;__do_fault+0x38/0xb0</div><div =
class=3D"">[ &nbsp;202.721280] =
&nbsp;__handle_mm_fault+0x73f/0x1080</div><div class=3D"">[ =
&nbsp;202.725467] &nbsp;? __switch_to_asm+0x34/0x70</div><div class=3D"">[=
 &nbsp;202.729390] &nbsp;? __switch_to_asm+0x40/0x70</div><div =
class=3D"">[ &nbsp;202.733318] =
&nbsp;handle_mm_fault+0xce/0x1f0</div><div class=3D"">[ =
&nbsp;202.737158] &nbsp;__do_page_fault+0x231/0x480</div><div class=3D"">[=
 &nbsp;202.741083] &nbsp;page_fault+0x2f/0x40</div><div class=3D"">[ =
&nbsp;202.744404] RIP: 0033:0x400c20</div><div class=3D"">[ =
&nbsp;202.747461] Code: 45 c8 48 89 c6 bf 32 0e 40 00 b8 00 00 00 00 e8 =
76 fb ff ff c7 45 ec 00 00 00 00 eb 36 8b 45 ec 48 63 d0 48 8b 45 c8 48 =
01 d0 &lt;0f&gt; b6 00 0f be c0 01 45 e4 8b 45 ec 25 ff 0f 00 00 85 c0 =
75 10 8b</div><div class=3D"">[ &nbsp;202.766208] RSP: =
002b:00007ffde95ae460 EFLAGS: 00010206</div><div class=3D"">[ =
&nbsp;202.771432] RAX: 00007ff71e855000 RBX: 0000000000000000 RCX: =
000000000000001a</div><div class=3D"">[ &nbsp;202.778558] RDX: =
0000000001dfd000 RSI: 000000007fffffe5 RDI: 0000000000000000</div><div =
class=3D"">[ &nbsp;202.785692] RBP: 00007ffde95af4b0 R08: =
0000000000000000 R09: 00007ff73d2a520d</div><div class=3D"">[ =
&nbsp;202.792823] R10: 0000000000000002 R11: 0000000000000246 R12: =
0000000000400850</div><div class=3D"">[ &nbsp;202.799949] R13: =
00007ffde95af590 R14: 0000000000000000 R15: 0000000000000000</div><div =
class=3D""><br class=3D""></div><div class=3D""><br class=3D""></div><div =
class=3D"">Further tests show that this also happens if one waits long =
enough on &nbsp;5.3-rc1 as well.</div><div class=3D"">So I don=E2=80=99t =
think we have a fix in tree yet.&nbsp;</div><div class=3D""><br =
class=3D""></div><div class=3D"">Cheers,</div><div =
class=3D"">Masoud</div><div class=3D""><br class=3D""></div><div><br =
class=3D""><blockquote type=3D"cite" class=3D""><div class=3D"">On Aug =
1, 2019, at 11:19 AM, Greg KH &lt;<a =
href=3D"mailto:gregkh@linuxfoundation.org" =
class=3D"">gregkh@linuxfoundation.org</a>&gt; wrote:</div><br =
class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">On Thu, Aug 01, 2019 at =
11:04:14AM -0700, Masoud Sharbiani wrote:</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D"">Hey folks,<br class=3D"">I=E2=80=99ve =
come across an issue that affects most of 4.19, 4.20 and 5.2 =
linux-stable kernels that has only been fixed in 5.3-rc1.<br class=3D"">It=
 was introduced by<br class=3D""><br class=3D"">29ef680 memcg, oom: move =
out_of_memory back to the charge path<span =
class=3D"Apple-converted-space">&nbsp;</span><br class=3D""><br =
class=3D"">The gist of it is that if you have a memory control group for =
a process that repeatedly maps all of the pages of a file with =
&nbsp;repeated calls to:<br class=3D""><br =
class=3D"">&nbsp;&nbsp;mmap(NULL, pages * PAGE_SIZE, =
PROT_WRITE|PROT_READ, MAP_FILE|MAP_PRIVATE, fd, 0)<br class=3D""><br =
class=3D"">The memory cg eventually runs out of memory, as it should. =
However,<br class=3D"">prior to the 29ef680 commit, it would kill the =
running process with<br class=3D"">OOM; After that commit ( and until =
5.3-rc1; Haven=E2=80=99t pinpointed the<br class=3D"">exact commit in =
between 5.2.0 and 5.3-rc1) the offending process goes<br class=3D"">into =
%100 CPU usage, and doesn=E2=80=99t die (prior behavior) or fail the =
mmap<br class=3D"">call (which is what happens if one runs the test =
program with a low<br class=3D"">ulimit -v value).<br class=3D""><br =
class=3D"">Any ideas on how to chase this down further?<br =
class=3D""></blockquote><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">Finding the exact patch that fixes this would be great, as =
then I can</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">add it to the =
4.19 and 5.2 stable kernels (4.20 is long end-of-life, no</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">idea why you are messing with =
that one...)</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" =
class=3D"">thanks,</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">greg k-h</span></div></blockquote></div><br =
class=3D""></div></body></html>=

--Apple-Mail=_EDBF6EA1-3636-447A-9165-8D973FD3B647--

--Apple-Mail=_4F8822D2-B7E4-4AD0-9773-8558C9BF4E33
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

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
Y2E1ZzEuZGVyMDgGCCsGAQUFBzABhixodHRwOi8vb2NzcC5hcHBsZS5jb20vb2NzcDAzLWFwcGxl
aXN0Y2E1ZzEwMTAfBgNVHREEGDAWgRRtc2hhcmJpYW5pQGFwcGxlLmNvbTCCASoGA1UdIASCASEw
ggEdMIIBGQYLKoZIhvdjZAULBQEwggEIMIHKBggrBgEFBQcCAjCBvQyBulJlbGlhbmNlIG9uIHRo
aXMgY2VydGlmaWNhdGUgYXNzdW1lcyBhY2NlcHRhbmNlIG9mIGFueSBhcHBsaWNhYmxlIHRlcm1z
IG9mIHVzZSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRzLiBUaGlzIGNlcnRp
ZmljYXRlIHNoYWxsIG5vdCBzZXJ2ZSBhcywgb3IgcmVwbGFjZSBhIHdyaXR0ZW4gc2lnbmF0dXJl
LjA5BggrBgEFBQcCARYtaHR0cDovL3d3dy5hcHBsZS5jb20vY2VydGlmaWNhdGVhdXRob3JpdHkv
cnBhMBMGA1UdJQQMMAoGCCsGAQUFBwMEMDcGA1UdHwQwMC4wLKAqoCiGJmh0dHA6Ly9jcmwuYXBw
bGUuY29tL2FwcGxlaXN0Y2E1ZzEuY3JsMB0GA1UdDgQWBBR5OmXQsx80at576fQVWG/05OardjAO
BgNVHQ8BAf8EBAMCBaAwDQYJKoZIhvcNAQELBQADggEBAMavb8+8hvTGbqNfz0g9P4Alj5YKpTnW
pt1NNuyl9qR+QVooK8oMbGTB6cbSSKX7lcAW7motP5eRF0EiKXiu+IIgPhmDWKkbKnrrWK9AGhVn
xpm3OCnRHt2b+zYbkGGty0HYncIRdy3acTr+0T9Vs4xANJHwBIqUnkW5XKbPiZkv+EVKAsnL5CYD
npLI/uslfLquUYe6o8XIBVNYhmxEcxeCXbeESEk/KutdL+JcV4SpNoEB6Y4Dk1ZnHYOZRiLV3ZEG
neaCYYxam7SPWxeXqLtgeQMEEPgqj6pj430BQ/NKmCqdwRv2Sd0wXlKEDMul7jmWVUiRd6Nijgy5
7E2hn9MxggMgMIIDHAIBATB2MGIxHDAaBgNVBAMTE0FwcGxlIElTVCBDQSA1IC0gRzExIDAeBgNV
BAsTF0NlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKEwpBcHBsZSBJbmMuMQswCQYDVQQG
EwJVUwIQDNpHL/RwufOMyUmvGQQ2czANBglghkgBZQMEAgEFAKCCAXswGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkwODAxMjIyNjUxWjAvBgkqhkiG9w0BCQQxIgQg
XVVfpGT2/ZIl1YMANTjbaga/Hk/uYRs/mLEyyY9i11UwgYUGCSsGAQQBgjcQBDF4MHYwYjEcMBoG
A1UEAxMTQXBwbGUgSVNUIENBIDUgLSBHMTEgMB4GA1UECxMXQ2VydGlmaWNhdGlvbiBBdXRob3Jp
dHkxEzARBgNVBAoTCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTAhAM2kcv9HC584zJSa8ZBDZzMIGH
BgsqhkiG9w0BCRACCzF4oHYwYjEcMBoGA1UEAxMTQXBwbGUgSVNUIENBIDUgLSBHMTEgMB4GA1UE
CxMXQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxEzARBgNVBAoTCkFwcGxlIEluYy4xCzAJBgNVBAYT
AlVTAhAM2kcv9HC584zJSa8ZBDZzMA0GCSqGSIb3DQEBAQUABIIBAHRvBRS7UpUEp4yOp7GF7AXU
U6nmxvuX7cMP49sK/C+LWiXiVvOHP7apmLORgOyov/ps3VRth7TxOytBzuQBasC3Ld3Mc6rdodgC
kxQHJ0tKSiWrp/LFu39Y7uTyMR/QhksWFqc/l9i0tX6iOHLjqPT8+UGUNMapLwa7UTRD5fKxJib0
SF5u61rrlhNb2S2mzyFG7NkHy5t2tKPUeBqWeayXveLvIEgTf0wZHx1u/oU/tPpfyoN89+3C/pbG
XC489WOY3+r43f03kqFA+nQ96Mde7aAQ3YKINoqfQ+dhbeUEUOwH/4nS+dHpSKtxjK5TaIdWoOG1
W277NqSdwqi6c1oAAAAAAAA=
--Apple-Mail=_4F8822D2-B7E4-4AD0-9773-8558C9BF4E33--

