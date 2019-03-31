Return-Path: <SRS0=Vnw4=SC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B66DC43381
	for <linux-mm@archiver.kernel.org>; Sun, 31 Mar 2019 16:15:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D078B20870
	for <linux-mm@archiver.kernel.org>; Sun, 31 Mar 2019 16:15:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.ca header.i=@yahoo.ca header.b="nrlAcoot"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D078B20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=yahoo.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 348EB6B0005; Sun, 31 Mar 2019 12:15:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F78F6B0006; Sun, 31 Mar 2019 12:15:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8076B0007; Sun, 31 Mar 2019 12:15:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2C6B6B0005
	for <linux-mm@kvack.org>; Sun, 31 Mar 2019 12:15:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p90so711897edp.11
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 09:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=yFLne+esl7CxqPkB1BSyS31PV8qDXzGe9+FkeRn80+U=;
        b=cqOk4TGnthRYX3lZ4K3wpfMaAzta3oNaxkQElUyiyloPQUnnW4RNRzO13OPhp6qVqs
         6sc0KiPW5FmbzkP6Bzg9e/kLFZGOSrhKaD8LvyGUrzNxjicjoyKS7wfM/gvhba5khQAo
         UAF9RZa05l9qYe3mbPlcU6eOryZpvGXdLg4nXqCxFiL6ty1tPH6fkiaHpNXkmdYEd90e
         YC3fyFFc9E1zmqlq+Agv/NvjpCN4MqZT5MerA7gCbGKX9Hjr5lCV+kGJxjssLd6/+dRZ
         ETfwU6rkdlKnpefvNYGo2jo5nFiXgi2D7RfFZbEPCN5DYN3dQ7wnl9vg1gFOSL4uE/wm
         m+Ww==
X-Gm-Message-State: APjAAAW/S4Uo+1FLyqOi9oQhcHx5Ej3nO8isYr2QzvMPZzw8n8V6KEyh
	7qpBgsKGV5SvURtKqqH+m0fiUpi1luGnuBJkZHRu6auTgtqIVArg9SfWr8TU/fnQD4PsBV+55Ap
	b8X1ezpEfnlKfFKfImr1ogOpuOjEpzGWyXD0pXPj8Zbw0C5etMR7w3sb8o5ot/LYCPQ==
X-Received: by 2002:a17:906:1c98:: with SMTP id g24mr32603925ejh.178.1554048948273;
        Sun, 31 Mar 2019 09:15:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1KxCuCzfZWucPADNRh7qAhFx0ZFR46+OEUqJZxhnRlr70ONPGNaG+6PlNE0pYyR7PpJxV
X-Received: by 2002:a17:906:1c98:: with SMTP id g24mr32603879ejh.178.1554048947197;
        Sun, 31 Mar 2019 09:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554048947; cv=none;
        d=google.com; s=arc-20160816;
        b=bjtVsDTxk143VQ3n7sGfKnJPKYSF8ctUWh8cwDv2hJgL1hwpqRgPkb+i7xO0NdXMRz
         8Gg8/M0im11Qz3HPMI0c+dfurpMqZZLj1O7+6ERJwKJQnIMxBytgYVxQblih04AGOVq4
         8uHoTwubLVPhrhIhscgy8FHFRXknMq8v/+k5EsZvmHfnYiVNo3PmrUwqK533OUK2fbvv
         SUlFP8W8+IMOWw/8yjhRiWHj22h+IgUAppdYTC4piq1/t5aF5R4ioLvSot+7kqSUEH28
         6erO/mZHnOieVODv7dxTdNbfZfaFnmNfwLWC5culoyZb8XplNUxq+ikSUf2GSD2YVEo5
         IKyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=yFLne+esl7CxqPkB1BSyS31PV8qDXzGe9+FkeRn80+U=;
        b=FtHEmN1ULLv1DTgElPzds01tXtPf7vd4oCceeddP8m53zlgvRNnTfsj4W2RT6h+rvl
         jhT2DUaSXaRQQcg/zPBCWcxjzNlDo3EUi76wir1Zh0SDTp5um8nXtPK+MgjE6STL/Qyw
         LQbZqxRWjehBQ8zLkqIa7ScELCuT9hNZn8K9nShTW/efssr1lCWwlB4jIGo9n9wsJy/Q
         ixIgSgFgftXR4zZ1TstSgep29BxErDy95FH9g26i+PQ5XXC6LCzAaEgNL3uZq2ocmJfe
         IiSaJ1i3CZFe/QmanBBKp6/U8PJNpwWSN3euAp1+cr/ooyy0agCEt+8Edo6IveSUfbLp
         L6aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yahoo.ca header.s=s2048 header.b=nrlAcoot;
       spf=pass (google.com: domain of alex_y_xu@yahoo.ca designates 77.238.177.32 as permitted sender) smtp.mailfrom=alex_y_xu@yahoo.ca;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.ca
Received: from sonic310-11.consmr.mail.ir2.yahoo.com (sonic310-11.consmr.mail.ir2.yahoo.com. [77.238.177.32])
        by mx.google.com with ESMTPS id v13si3356793edc.285.2019.03.31.09.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Mar 2019 09:15:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of alex_y_xu@yahoo.ca designates 77.238.177.32 as permitted sender) client-ip=77.238.177.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yahoo.ca header.s=s2048 header.b=nrlAcoot;
       spf=pass (google.com: domain of alex_y_xu@yahoo.ca designates 77.238.177.32 as permitted sender) smtp.mailfrom=alex_y_xu@yahoo.ca;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.ca; s=s2048; t=1554048946; bh=yFLne+esl7CxqPkB1BSyS31PV8qDXzGe9+FkeRn80+U=; h=Date:From:Subject:To:Cc:References:In-Reply-To:From:Subject; b=nrlAcoot1uXd2QzH9anR3TKwP9RVm/85iGBvC8d2khbRpCbE2UjyMnbOwTBECJ3zCS6bPbJMC7wwM1VUtz0XdEl6M8X7F5gVrF1wXIPJWsh4pwJyXQyF+fe06XIrqu3POIc3wXjokLXtqVK2omVT45hpK+YivQLj+N35EFQDphwzVmrkbdqRDsHvhUhN53yjiX5lXxxdgdgyGThb+FNpG9GJoXxRP/u20qIA3uk9kWixRMageAeuSZXy4ZXHzEkEeDZ+CZQgqKbLHsxilNmXmz2bL9J7wHNE1OIOP+TS0jrQIBomf14ie0G2B5nTwrX/UxARDXalvX116kHvzi1QdA==
X-YMail-OSG: Ob5dIF8VM1kWQZZYrrM1z3U0Libo0Qx.97fi_4C3zTHXV1B6s1liY1jo3JYgtUA
 0Cte2u5hWUNXCu3LcGOBQrBSI.FaR2tLcfHJbUwV2Fj9XBG0tEv1Wi731FxqHh5HmZQigeGUinME
 _Ztstdrcecjignyc6leT5NvL4QXHVII69jsphxIQcty8BA.pQ79qCKTVlJqWt2Hp63aFNg9bGpzr
 AiJCOqwlnBdgiFBmlBQcmGzLcdWfjxR1BtYku2xdZBXXfsp_bPcDFTYO5eozTijXbkRY8ZXv4F0B
 gg_pK3pv_rvA.L3QpkS.mzUz1BJCxSljZkNB9.Vg1xg7YVyajm2.HuxuvtA77BKv7MdNyBAkVhJ5
 DaniX7mr5bRpqOtf7LVlnH57lRUrgL1lO8Dxdwn9dFUdqdDW.VJH9kNbmCDk4_HU_yf0gUzHMiT1
 NsZmzFXJbHsPQ0HC2AXm7QrHqbZk6zfqTHS0GfmK9kUh70W3SUoQggPN.lWBHv0kpAxELErhQ4yL
 8a2lkMUU5D1V.1.24Q9z6jFzjljO9CrCbWQLRZKAO4uOnE4tz63IZc3VSmE7WHIfDSm9t5swIHNP
 .V.WQYDFSUlFt55NZ0RC.0AB.Ku8EPfS9CANwJTPefYyyiqcj4lZ2Hzg721YeV.v8m4KzHoxuA4T
 knC97aY2vxQbS9HPkpSlN_4ugbtJpax5wrSYgC0xRUgQwZy4O3XnDiZ5L9.PZmAA1JFpquomnqPc
 vAzRNNucRt8dUNUKQsbDdm30ecKL3Os4WcwtLR_boVad3S5FbEJ1mf_fatdpk.GGgIWBNw9xlsjf
 aAmInuD81b.hyHuG5k8dCjqrRIocal_sVyNyE2Fkg27uLKxCcI3CZrAGWQdWz5jSP3IfmIHFZmh9
 w3WcohBiloGq45bBVtb_zlK8eVPRzrVuANrfjeDmgDPWJtTw3y5qbT7d6iaI92gy8d4qkKi1ode_
 rsJb0Elb.6iSXUqC4ZaCvnAvop6S3W_WiHJR0hk5vrbmzGsF2jcttSXab0gsk0KCULcdS8w4AwYw
 CnEXMIZwKosYZGhQcarqZ4Fn5gmu1XE7re8w53sA.I4uluaw3xDi8E36n8C73IBzg8lA-
Received: from sonic.gate.mail.ne1.yahoo.com by sonic310.consmr.mail.ir2.yahoo.com with HTTP; Sun, 31 Mar 2019 16:15:46 +0000
Received: from pink.alxu.ca (EHLO localhost) ([198.98.62.56])
          by smtp430.mail.ir2.yahoo.com (Oath Hermes SMTP Server) with ESMTPA ID 33cc58c9291985f5d2394688291da901;
          Sun, 31 Mar 2019 16:15:41 +0000 (UTC)
Date: Sun, 31 Mar 2019 12:15:36 -0400
From: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
To: Vineeth Pillai <vpillai@digitalocean.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins
	<hughd@google.com>, Kelley Nielsen <kelleynnn@gmail.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel
	<riel@surriel.com>, Huang Ying <ying.huang@intel.com>
References: <1553440122.7s759munpm.astroid@alex-desktop.none>
	<CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com>
In-Reply-To: <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1554048843.jjmwlalntd.astroid@alex-desktop.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Excerpts from Vineeth Pillai's message of March 25, 2019 6:08 pm:
> On Sun, Mar 24, 2019 at 11:30 AM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> w=
rote:
>>
>> I get this BUG in 5.1-rc1 sometimes when powering off the machine. I
>> suspect my setup erroneously executes two swapoff+cryptsetup close
>> operations simultaneously, so a race condition is triggered.
>>
>> I am using a single swap on a plain dm-crypt device on a MBR partition
>> on a SATA drive.
>>
>> I think the problem is probably related to
>> b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.
>>
> Could you please provide more information on this - stack trace, dmesg et=
c?
> Is it easily reproducible? If yes, please detail the steps so that I
> can try it inhouse.
>=20
> Thanks,
> Vineeth
>=20

Some info from the BUG entry (I didn't bother to type it all,=20
low-quality image available upon request):

BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
#PF error: [normal kernel read fault]
PGD 0 P4D 0
Oops: 0000 [#1] SMP
CPU: 0 Comm: swapoff Not tainted 5.1.0-rc1+ #2
RIP: 0010:shmem_recalc_inode+0x41/0x90

Call Trace:
? shmem_undo_range
? rb_erase_cached
? set_next_entity
? __inode_wait_for_writeback
? shmem_truncate_range
? shmem_evict_inode
? evict
? shmem_unuse
? try_to_unuse
? swapcache_free_entries
? _cond_resched
? __se_sys_swapoff
? do_syscall_64
? entry_SYSCALL_64_after_hwframe

As I said, it only occurs occasionally on shutdown. I think it is a safe=20
guess that it can only occur when the swap is not empty, but possibly=20
other conditions are necessary, so I will test further.

