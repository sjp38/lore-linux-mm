Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 636ADC04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:06:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 174AE21883
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:06:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XpHCXZ0v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 174AE21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A81126B0006; Fri, 17 May 2019 20:06:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A31B86B0008; Fri, 17 May 2019 20:06:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D3796B000A; Fri, 17 May 2019 20:06:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC676B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 20:06:10 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id y13so8067858qtc.7
        for <linux-mm@kvack.org>; Fri, 17 May 2019 17:06:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=qUU/PCHJ10Cnm4pEYGt2NYLBE8MczWcaqgp3zO0rTb0=;
        b=eLu381XG6VyR3WiSEyyFhNKVJO9NBdJwHFMts0AgRmc258qrvRJQGT8waGWDFzErpt
         cblSOnWRILT3A5d9Xj5DgyiTRvN6tIFZHJoUkcBVeJAP4JfjGwC4Zk/nF5TfvAXUjFi0
         EBhjQLRbNm9zX4E2/9BTBpEjMl+h8agsso4HP3RTvgNLxCg/dFqaNuq/1NubU+oeBo/P
         Qc/saCbDg4ww7lSxhPnUsHi8s9HDiXPwxsxPTU42VHGsRIYS4SAD0CRdz0uzeMsS2BXn
         cqBlcB6RqMDRmoDLUeJYO/bk47Lb7ifQl0nOXNhcdQbB5slrdnY05tf25LTjlR1hZsNy
         P7+g==
X-Gm-Message-State: APjAAAW6CKu/4DQ3hfbLRVdQ4oO8Rr0MgT4fb2KyU1cR0SSrgGpFkwdm
	SMBsbT4eRmWwJFbFJnzpvMkwIo+93BRBiWvE7v9YM0jHJvFyvZK95Po2WtIMhmEfrPn7PYOq5zc
	UZHQ6AAbohIbnjyJIL3F4nUQ7BHNc1wd2Oew37f3sjd9A5ViHd4HgKNmZPwE+3xp0ew==
X-Received: by 2002:a0c:d92e:: with SMTP id p43mr9201355qvj.29.1558137970148;
        Fri, 17 May 2019 17:06:10 -0700 (PDT)
X-Received: by 2002:a0c:d92e:: with SMTP id p43mr9201304qvj.29.1558137969547;
        Fri, 17 May 2019 17:06:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558137969; cv=none;
        d=google.com; s=arc-20160816;
        b=AJOPabeSRZPi+5sGeJt6ICEzDoIHDOoOaBB2o/1pv438fYFPbNMZB93FeNYveu0N7l
         Rpd0ILNh2grrZ/p349v0Bb+7Amt4/Q73esuKg2UW9nnv0umevpSkrYRnK+XQAk73qmX3
         BxjZPMh1f3rJ9e1Ah/7vX2umDpYF3y2/BLdkqjLOkMWgKdQnvsb6Bfb3UffqaGn2FX4D
         Iyl014oJbzfSuY95a3oQrxkzIM/aysiTJnrlriiSirP3qICsJ5nhqFhTpTlaL1pAC9UC
         vsdUDS+vHdxpzvjLlRPcr1MNSkUI5nf8wjHV/yI6fnyEksXd+DQ/zHAvpYEI4iGDUbkP
         dkkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=qUU/PCHJ10Cnm4pEYGt2NYLBE8MczWcaqgp3zO0rTb0=;
        b=hBpdqsw/m8oCuw59V9KJHpGF4dFkO+MjIxqd8/Frh7c3+mxEtwUHq6yISDU8r26rfn
         RQjtvHeSrQJx5X3zwEszQD+CvM54IKzeeRtdGvw825ak98VdSOQ4mGVgMNr+oXaIMeVT
         dmEURRw+7rqu1TGLvnabcXF91Tytiir26bUj8N21hTwQx1eKXjWiqoclbd7S+fW7lxI/
         PV2VI9sAjTp7ISvPKL5TKVPLKWxX97akIP4LHAJQM8OctARvN59NfZq5dX6KrlMz4/6n
         IVtfyPL6X8AHGujYRAAoXNBwwe4XhX9OHKm5B9K/2Ft5XsurazyqEnqdiWvQyUbUGBSx
         EncA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XpHCXZ0v;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p26sor5792236qkk.79.2019.05.17.17.06.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 17:06:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XpHCXZ0v;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=qUU/PCHJ10Cnm4pEYGt2NYLBE8MczWcaqgp3zO0rTb0=;
        b=XpHCXZ0vlW6ZB0LjNM3gSWk+gqE+tUaKl7t5x0Uy0r30UxhLbJy+WPkVwwq+x9/KQw
         +CRNhMn/4++Gq8rK/DF2O3PN4lwDVocPTCjf90D6TQL/JFiByl1VKPohza0LgoggQUBz
         PBQbfib83VzeF6lJ7d6/ERQaZw7rah61nnorKe+b9YXK0B+pXNDa5VZsNEEl7foC4tjD
         1/Bh+WHotDx8JFM0DJ3sa09ujJ/a8zWFMl0O2QphX/caCiFP54RYDbSlvUZFlGbJK594
         7fySsbMJ780nVzcYMRutROAriGZ/5rGlAuaXRPOzLRCsbglNSZkVH0rCdmrEB4TiipDl
         cTYg==
X-Google-Smtp-Source: APXvYqx9dlDkMrn2MOaCbua3SEWTUfkJSCGmXC5rRUtuNpy08kKWyNNzYC2LUnAUQvuDM1Xcl2tLkYeLd/8PvwCfoRM=
X-Received: by 2002:a37:4948:: with SMTP id w69mr49213504qka.122.1558137968878;
 Fri, 17 May 2019 17:06:08 -0700 (PDT)
MIME-Version: 1.0
References: <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net> <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com> <20190514170522.GW2623@hirez.programming.kicks-ass.net>
 <20190514180936.GA1977@linux.intel.com> <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com>
 <20190514210603.GD1977@linux.intel.com> <A1EB80C0-2D88-4DC0-A898-3BED50A4F5A8@amacapital.net>
 <20190514223823.GE1977@linux.intel.com>
In-Reply-To: <20190514223823.GE1977@linux.intel.com>
From: Jonathan Adams <jwadams@google.com>
Date: Fri, 17 May 2019 17:05:32 -0700
Message-ID: <CA+VK+GOL_sY5aWYijg1_X6VgvDtFbRX2ymuSXhsZeZH2_tO2qg@mail.gmail.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jan Setje-Eilers <jan.setjeeilers@oracle.com>, 
	Liran Alon <liran.alon@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 3:38 PM Sean Christopherson
<sean.j.christopherson@intel.com> wrote:
> On Tue, May 14, 2019 at 02:55:18PM -0700, Andy Lutomirski wrote:
> > > On May 14, 2019, at 2:06 PM, Sean Christopherson <sean.j.christophers=
on@intel.com> wrote:
> > >> On Tue, May 14, 2019 at 01:33:21PM -0700, Andy Lutomirski wrote:
> > >> I suspect that the context switch is a bit of a red herring.  A
> > >> PCID-don't-flush CR3 write is IIRC under 300 cycles.  Sure, it's slo=
w,
> > >> but it's probably minor compared to the full cost of the vm exit.  T=
he
> > >> pain point is kicking the sibling thread.
> > >
> > > Speaking of PCIDs, a separate mm for KVM would mean consuming another
> > > ASID, which isn't good.
> >
> > I=E2=80=99m not sure we care. We have many logical address spaces (two =
per mm plus a
> > few more).  We have 4096 PCIDs, but we only use ten or so.  And we have=
 some
> > undocumented number of *physical* ASIDs with some undocumented mechanis=
m by
> > which PCID maps to a physical ASID.
>
> Yeah, I was referring to physical ASIDs.
>
> > I don=E2=80=99t suppose you know how many physical ASIDs we have?
>
> Limited number of physical ASIDs.  I'll leave it at that so as not to
> disclose something I shouldn't.
>
> > And how it interacts with the VPID stuff?
>
> VPID and PCID get factored into the final ASID, i.e. changing either one
> results in a new ASID.  The SDM's oblique way of saying that:
>
>   VPIDs and PCIDs (see Section 4.10.1) can be used concurrently. When thi=
s
>   is done, the processor associates cached information with both a VPID a=
nd
>   a PCID. Such information is used only if the current VPID and PCID both
>   match those associated with the cached information.
>
> E.g. enabling PTI in both the host and guest consumes four ASIDs just to
> run a single task in the guest:
>
>   - VPID=3D0, PCID=3Dkernel
>   - VPID=3D0, PCID=3Duser
>   - VPID=3D1, PCID=3Dkernel
>   - VPID=3D1, PCID=3Duser
>
> The impact of consuming another ASID for KVM would likely depend on both
> the guest and host configurations/worloads, e.g. if the guest is using a
> lot of PCIDs then it's probably a moot point.  It's something to keep in
> mind though if we go down this path.

One answer to that would be to have the KVM page tables use the same
PCID as the normal user-mode PTI page tables.  It's not ideal (since
the qemu/whatever process can see some kernel data via meltdown it
wouldn't be able to normally see), but might be an option to
investigate.

Cheers,
- jonathan

