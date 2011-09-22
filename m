Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DCF139000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 11:44:39 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8MFibKs023514
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:44:37 -0700
Received: from gyf2 (gyf2.prod.google.com [10.243.50.66])
	by wpaz33.hot.corp.google.com with ESMTP id p8MFiMh8004438
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:44:36 -0700
Received: by gyf2 with SMTP id 2so2315374gyf.41
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:44:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110922095803.GA4530@shutemov.name>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
 <1316393805-3005-7-git-send-email-glommer@parallels.com> <CAHH2K0Yuji2_2pMdzEaMvRx0KE7OOaoEGT+OK4gJgTcOPKuT9g@mail.gmail.com>
 <20110922095803.GA4530@shutemov.name>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 22 Sep 2011 08:44:11 -0700
Message-ID: <CAHH2K0ZMq_jCGr3m3PZDtmDwHUXnnL-fuQDt-A-SdUKgeK6P6g@mail.gmail.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 22, 2011 at 2:58 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Sep 21, 2011 at 11:01:46PM -0700, Greg Thelen wrote:
>> On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> w=
rote:
>> > +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
>> > +{
>> > + =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);
>> > +}
>> > +
>>
>> Why are you adding a copy of mem_cgroup_is_root(). =A0I see one already
>> in v3.0. =A0Was it deleted in a previous patch?
>
> mem_cgroup_is_root() moved up in the file.

Got it.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
