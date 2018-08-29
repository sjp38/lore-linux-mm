Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 670EB6B4C55
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:14:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id y32-v6so3662422wrd.19
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 08:14:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 132-v6sor1055271wmi.0.2018.08.29.08.14.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 08:14:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180821064911.GW29735@dhcp22.suse.cz> <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
 <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz> <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
In-Reply-To: <20180829150136.GA10223@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 29 Aug 2018 17:13:59 +0200
Message-ID: <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000002acb6c05749469b9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

--0000000000002acb6c05749469b9
Content-Type: text/plain; charset="UTF-8"

>
> trace data which starts _before_ the cache dropdown starts and while it
> is decreasing should be the first step. Ideally along with /proc/vmstat
> gathered at the same time. I am pretty sure you have some high order
> memory consumer which forces the reclaim and we over reclaim. Last data
> was not really conclusive as it didn't really captured the dropdown
> IIRC.
>

with before you mean in a totally healthy state?
as I can not tell when decreasing starts this would mean collecting data
over days perhaps. however, I have no issue with that.
As I do not want to miss anything that might help you, could you please
provide the commands for all the data you require?
one host is at a healthy state right now, I'd run that over there
immediately.

--0000000000002acb6c05749469b9
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote"><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">
<br>
trace data which starts _before_ the cache dropdown starts and while it<br>
is decreasing should be the first step. Ideally along with /proc/vmstat<br>
gathered at the same time. I am pretty sure you have some high order<br>
memory consumer which forces the reclaim and we over reclaim. Last data<br>
was not really conclusive as it didn&#39;t really captured the dropdown<br>
IIRC.<br></blockquote><div><br></div><div>with before you mean in a totally=
 healthy state?</div><div>as I can not tell when decreasing starts this wou=
ld mean collecting data</div><div>over days perhaps. however, I have no iss=
ue with that.</div><div>As I do not want to miss anything that might help y=
ou, could you please</div><div>provide the commands for all the data you re=
quire?</div><div>one host is at a healthy state right now, I&#39;d run that=
 over there immediately.</div><div><br></div><div><br></div></div></div>

--0000000000002acb6c05749469b9--
