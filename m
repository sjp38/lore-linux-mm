Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BA2DC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:18:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3809B2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:18:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="De16ed2X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3809B2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB2226B026B; Thu, 11 Apr 2019 12:18:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C60FB6B026C; Thu, 11 Apr 2019 12:18:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4F346B026D; Thu, 11 Apr 2019 12:18:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9384D6B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:18:47 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z24so6001758qto.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:18:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=dtBnB10BHscANlI2Pry7Ppm8oEPt+C4ZM4LG9RdUtdk=;
        b=rf2COIBSyPPqAxDBrl2aXtpb4gpuRCt2UHMcgfgxVP67AmCEPB0nykYol2x0W5nhg9
         2WlbV5LifWywkTehppcyANQFKEHVbSGUoj8S5ypB/JyAl+Mtr4svs1llCg1YZBMgZAQ8
         UBlN9lR79SRk2JhU1vooA6SM2TmL0xkPIsgKs8XHfNztUeICSxAkpuqUJGSA8xOA++6k
         hd0QVQ7IbxOrG+5NRY8aU3qXE65jkT7l2JZ765o0+yV7O2bl6nXFJ2KKl6ZslpwW7/Fv
         MfsvGeUi71Zlhk4nbPw2Jsj4jLDNF9/BSEyH/f8oXaL23talHVWhjapvDwRb8aKhKMZF
         BJSw==
X-Gm-Message-State: APjAAAWEHc9zqQNql+QPPAR49B0vU8YduNUjsqDNuklc8xr+5alsy/NL
	WEfUAlngH4U7ZVECCtGveHS26dEat+YnZI5hwY8N7GfMYEZRLxgRk1pZCUdG6ynNS0Wx8LOoQ/r
	j3vfsHX8QH38PbvohDJ/svhpTgYpQglwMnZs6Wi+8Mq7NizZLi2ksD6yc4kdJ729mMQ==
X-Received: by 2002:a0c:986d:: with SMTP id e42mr41344920qvd.51.1554999527210;
        Thu, 11 Apr 2019 09:18:47 -0700 (PDT)
X-Received: by 2002:a0c:986d:: with SMTP id e42mr41344794qvd.51.1554999525790;
        Thu, 11 Apr 2019 09:18:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554999525; cv=none;
        d=google.com; s=arc-20160816;
        b=Wd7NPAaMLwXyXyCcvKRD/ac+HjatzKFGYGIcYk3QaOIfqmhSmo0LojF4UfWeBx1+OL
         RLs6NW+2mkujwo6H6XRKxHxwnr4S8UWwMCiY4ZHxoMI028Ar/nZHkHDXn4anUkPp1LhP
         chzdth/Z8MlPiZWCrOVVs9cpGUj1KQOuDCmdif79u9lz4UMBnrrZ7o3uvRYEFQIfJAvF
         JcqCSCBTVaB9wb3wvdrvZtHyAxZvNV8sHYA8WtjgnMjprSC5YjVu20D5l+6SWSo61mGF
         +SSATlgOTvlNqoxLbJ/fMCyJaay0eCm3LfOcsyVOT5KkmPpzNc8fp3b+MtRH6R92f3NM
         +U3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=dtBnB10BHscANlI2Pry7Ppm8oEPt+C4ZM4LG9RdUtdk=;
        b=l55dtMJrgvQ9JiKlgsDyzI3fT4cr+DerIWPT3M61jW7NG+mQKYyTXOyNNWdzDUbLlB
         W8BRlzpi5jg/ddDN9jZKmqk2mRUqNfwlJbXv+/umz/q4x0/Ty2EAL3gqZLhGeqBfz0Wf
         lJewcag+ex5fEhgOfMJ1/itK9TFcVmHhWT53ZU359DBaa8qiHnDhAHu9EJNF5Plxq0gc
         l8eIWUlbDBocjBFiE/HU+M+RZEpJmuZGY1T6gQGu0pYDSthQWxp3Fzc/PqIWah4chzOq
         zLkX9sSlxtcBXbIq+HntdmX/R2MtePHCwkuPCsNdeNjfTQGltY7hYmJCteR54VteTvhS
         pljg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=De16ed2X;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k37sor31655780qte.10.2019.04.11.09.18.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:18:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of joelaf@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=De16ed2X;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=dtBnB10BHscANlI2Pry7Ppm8oEPt+C4ZM4LG9RdUtdk=;
        b=De16ed2XEEtRbo1CKENs6sMutHD49Q/cAstG3x5wpdUx4DYv3vn40aZ7zGxs9pKUVk
         ek9QFv0RYGM538H15uQSE5LbohaaIJCUg3LcLe/YhVbL6RalwlCudvAPNrrnoKElWsFy
         JbF/ndTJJqlDbBBt3CnWLC2x1CfLe3+PtzByzBGTFse0rpiDiCHpCqH597QWvGbXVEyG
         FEtE4zye0+fCtu9PhwqVIEGGh9u/EPP+2pTHpDHfkdI4CPDLNUN3oGq220fh2X2a8qHw
         NgNJikpyAVpALN8w62AAEgQHCP1yb5FfC3P6SpnQjNJU4Kkr2Kpre+vEGC8ZjZKo8Gl5
         o8SA==
X-Google-Smtp-Source: APXvYqx5CWpGgbACybyrinBfzS83tX4KRJs57zlMkMYYYLfTduHXBqgvj3424Yc5issdUsStUoC8yj5bc9QGP2WynL0=
X-Received: by 2002:ac8:1a21:: with SMTP id v30mr42590152qtj.103.1554999525039;
 Thu, 11 Apr 2019 09:18:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411105111.GR10383@dhcp22.suse.cz>
In-Reply-To: <20190411105111.GR10383@dhcp22.suse.cz>
From: Joel Fernandes <joelaf@google.com>
Date: Thu, 11 Apr 2019 12:18:33 -0400
Message-ID: <CAJWu+oq45tYxXJpLPLAU=-uZaYRg=OnxMHkgp2Rm0nbShb_eEA@mail.gmail.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	David Rientjes <rientjes@google.com>, Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com, 
	jrdr.linux@gmail.com, guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>, 
	penguin-kernel@i-love.sakura.ne.jp, ebiederm@xmission.com, 
	shakeelb@google.com, Christian Brauner <christian@brauner.io>, 
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>, 
	Daniel Colascione <dancol@google.com>, "Joel Fernandes (Google)" <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, 
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, 
	"Cc: Android Kernel" <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 6:51 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> [...]
> > Proposed solution uses existing oom-reaper thread to increase memory
> > reclaim rate of a killed process and to make this rate more determinist=
ic.
> > By no means the proposed solution is considered the best and was chosen
> > because it was simple to implement and allowed for test data collection=
.
> > The downside of this solution is that it requires additional =E2=80=9Ce=
xpedite=E2=80=9D
> > hint for something which has to be fast in all cases. Would be great to
> > find a way that does not require additional hints.
>
> I have to say I do not like this much. It is abusing an implementation
> detail of the OOM implementation and makes it an official API. Also
> there are some non trivial assumptions to be fullfilled to use the
> current oom_reaper. First of all all the process groups that share the
> address space have to be killed. How do you want to guarantee/implement
> that with a simply kill to a thread/process group?

Will task_will_free_mem() not bail out in such cases because of
process_shares_mm() returning true? AFAIU, Suren's patch calls that.
Also, if I understand correctly, this patch is opportunistic and knows
what it may not be possible to reap in advance this way in all cases.
        /*
         * Make sure that all tasks which share the mm with the given tasks
         * are dying as well to make sure that a) nobody pins its mm and
         * b) the task is also reapable by the oom reaper.
         */
        rcu_read_lock();
        for_each_process(p) {
                if (!process_shares_mm(p, mm))

> > Other possible approaches include:
> > - Implementing a dedicated syscall to perform opportunistic reclaim in =
the
> > context of the process waiting for the victim=E2=80=99s death. A natura=
l boost
> > bonus occurs if the waiting process has high or RT priority and is not
> > limited by cpuset cgroup in its CPU choices.
> > - Implement a mechanism that would perform opportunistic reclaim if it=
=E2=80=99s
> > possible unconditionally (similar to checks in task_will_free_mem()).
> > - Implement opportunistic reclaim that uses shrinker interface, PSI or
> > other memory pressure indications as a hint to engage.
>
> I would question whether we really need this at all? Relying on the exit
> speed sounds like a fundamental design problem of anything that relies
> on it. Sure task exit might be slow, but async mm tear down is just a
> mere optimization this is not guaranteed to really help in speading
> things up. OOM killer uses it as a guarantee for a forward progress in a
> finite time rather than as soon as possible.

Per the data collected by Suren, it does speed things up. It would be
nice if we can reuse this mechanism, or come up with a similar
mechanism.

thanks,

 - Joel

