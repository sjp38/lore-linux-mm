Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C3FAC32751
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 16:08:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 830FD2086A
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 16:08:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DDbJE32I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 830FD2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8FC86B0005; Sat, 10 Aug 2019 12:08:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D40FB6B0006; Sat, 10 Aug 2019 12:08:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C08956B0007; Sat, 10 Aug 2019 12:08:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 943D86B0005
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 12:08:32 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id t26so5013748otm.9
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 09:08:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6KSVc9KwDQ8mYXRHbWP5V3VP0yPXzP96KwfAHAlRm1Y=;
        b=mIN/CUgUUlN+Jh+1Cz3/gXTR6R0jKyF/wzpSaKV6Nk6Zg5Vkub3kwG59mP329djdmW
         STU0TP/d9EoF2KLAcaZBDYNtUcg0y0auSLFO5VJ+/uUbJOyrzB9Kssz0OokQ3k4pb7Jk
         /1Eq8pidcOn+LCWn4w5bQB9JQRbU1RsZ4MG71Og8a/8EUSLGzKqy0uHbaK8iD/XFN7tM
         0eDwEUT5Nsf+4A5ZXBfCgamh1M7l6JHE3YNIidGHPv25dkmTB0DuNG7Nty8Nh7Bt0ABy
         tMjyuH2ADHprnSu8VkgwM0jCd7wDopJNibkxD+j62DA9faW4g3Kgiue3cf1c4RttZ9rE
         8gmQ==
X-Gm-Message-State: APjAAAWIC8tf+YZP4lyE7PmeCzIcCdL0y3Xuk3xuIW+IVbsk7bRya0Kh
	1D5UmeSHAOk7iT2cVWgpRtVdSC2neTl+9qF6FMq7k9uZscK2iTItuNBxS0iiSd+F0Vs0Xl57Xp0
	MYxsvYLQMQ9MK0Mg+0NtTdehEkOoChctNH2p54jbyq7zLeGZOeOszBa89w1mQ+zUolw==
X-Received: by 2002:a6b:90c3:: with SMTP id s186mr27359977iod.114.1565453312176;
        Sat, 10 Aug 2019 09:08:32 -0700 (PDT)
X-Received: by 2002:a6b:90c3:: with SMTP id s186mr27359938iod.114.1565453311499;
        Sat, 10 Aug 2019 09:08:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565453311; cv=none;
        d=google.com; s=arc-20160816;
        b=g8DQOqcT/e6Qyk1F0yghR1iJGP0V8EIS7s+1cvmssZiFInx6W1+pBsBy8bfvrWmzQK
         3x/oyI42DU6rec0kzTccfF3bKZc7Vl/UkF0yBQF5mO1UKpJimjpTWGmohRvWOTAdeQzO
         c4IxP0cwtaFWgQdRDdOcY8tVrbFLyHejLC7FYUPiVg5WCJuAK98pFsVLkzuVWrzAXCqn
         yDC4EvypauwhR8M0/3DAR1bK6XVnSLWuyhZOAPxvlbAPUr12foFV2+U4YyzGiaJlo7of
         v1sd2p9biToO25JBBcrninIOPSHWLy1W0zWQBWMnbgIy7kcwWMwkuRVNt9//1oOH/H/O
         DAxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6KSVc9KwDQ8mYXRHbWP5V3VP0yPXzP96KwfAHAlRm1Y=;
        b=UUup9tvNyyLjdo0VWX4sKv3ddp8XT/kMD6zPlpgTgU+P11u48TM1aoupf+oiCCFVsS
         OWTOJXolGCtxrG9LVOx6kbuNiXL61iyQNMA2eKw06wOIJDMNm2LKzwyt3horaETp8TDZ
         FVlr6HFSOLAetoWPWfSOqxoa53vgsYXoyP9LbmiMa37Gy8wQB8457CCdSJMn4Ns32Udc
         F3TM4Cw718Qr+LmCnQ1yBzkDpsl3WLcVlf2GLHbN5sCLQ9TOO72tzqeXwxshpTk+RqC4
         7dNbBLCgS4YS2E8PDMWT5nqEvMm4Lj/6/bgniX8j/Is+nY5TQiFom5uO7+sG5cgAx9gM
         ojnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DDbJE32I;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 131sor22849091jac.14.2019.08.10.09.08.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 09:08:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DDbJE32I;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6KSVc9KwDQ8mYXRHbWP5V3VP0yPXzP96KwfAHAlRm1Y=;
        b=DDbJE32IHdgZ6K44/Mi25TSjhfLNI+Pv7vV7h6WPt3KhKCos3tPkQtsaRQcOlrnCao
         pC6OcYZywjpWqkQpb0aTjoOCOPmdMIHimRhNHBBux1hEJwKA1H61N4aSaWgCQr0cOLmV
         uqSqIoJlBNjYjqT8n19jqaXFmXFi/7W0QoG4wC+ZoYeSPmUtfDyDrmrqlBEGahLqG6Ny
         26WXuZDRFYsKFZ0/Ho8xrGURkjsDlG/g7QI2fKU3yewrCbZaxVY1WmYGlTEfe21xPXo9
         O9FTCZ2vWEAkyY10hplAq6QtcCVBHUWb8bKktGgCfED8qIlWRchqyIA0wgX28jqlYh6S
         uayQ==
X-Google-Smtp-Source: APXvYqwnsA1Hh5iMtQsab6uFw4b0TK+0JNZTXxOU+oTZlyzRYrhwHoz8L309HXmPBJrYVjLiRU2JqEZrPGPv8nyoYW4=
X-Received: by 2002:a02:bb05:: with SMTP id y5mr28400578jan.93.1565453310708;
 Sat, 10 Aug 2019 09:08:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190806014830.7424-1-hdanton@sina.com> <CABXGCsMRGRpd9AoJdvZqdpqCP3QzVGzfDPiX=PzVys6QFBLAvA@mail.gmail.com>
 <CADnq5_O08v3_NUZ_zUZJFYwv_tUY7TFFz2GGudqgWEX6nh5LFA@mail.gmail.com>
 <6d5110ab-6539-378d-f643-0a1d4cf0ff73@daenzer.net> <CADnq5_P=gtz_8vNyV7At73PngbNS_-cyAnpd3aKGPUFyrK64EA@mail.gmail.com>
 <CABXGCsPeeHWUYCuAiZVSbn1Pq2mKK1umtcRYZFcG4z9712xdDg@mail.gmail.com>
In-Reply-To: <CABXGCsPeeHWUYCuAiZVSbn1Pq2mKK1umtcRYZFcG4z9712xdDg@mail.gmail.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sat, 10 Aug 2019 21:08:19 +0500
Message-ID: <CABXGCsPejOrb4yb3THfp6w+Od7ZAgQRpeCvYRhsTLZqJQdGYUQ@mail.gmail.com>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
To: Alex Deucher <alexdeucher@gmail.com>
Cc: =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel@daenzer.net>, 
	Hillf Danton <hdanton@sina.com>, Dave Airlie <airlied@gmail.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, Harry Wentland <harry.wentland@amd.com>, 
	"Koenig, Christian" <Christian.Koenig@amd.com>
Content-Type: multipart/mixed; boundary="000000000000800e78058fc58002"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000800e78058fc58002
Content-Type: text/plain; charset="UTF-8"

On Fri, 9 Aug 2019 at 23:55, Mikhail Gavrilov
<mikhail.v.gavrilov@gmail.com> wrote:
> Finally initial problem "gnome-shell: page allocation failure:
> order:4, mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
> nodemask=(null),cpuset=/,mems_allowed=0" did not happens anymore with
> latest version of the patch (I tested more than 23 hours)
>
> But I hit a new problem:
>
> [73808.088801] ------------[ cut here ]------------
> [73808.088806] DEBUG_LOCKS_WARN_ON(ww_ctx->contending_lock)
> [73808.088813] WARNING: CPU: 8 PID: 1348877 at
> kernel/locking/mutex.c:757 __ww_mutex_lock.constprop.0+0xb0f/0x10c0

[pruned]

> So I needed to report it separately (in another thread) or we continue here?

Today after reboot issue "DEBUG LOCKS
WARN_ON(ww_ctx->contending_lock)" happened again.

--
Best Regards,
Mike Gavrilov.

--000000000000800e78058fc58002
Content-Type: text/plain; charset="US-ASCII"; name="dmesg2.txt"
Content-Disposition: attachment; filename="dmesg2.txt"
Content-Transfer-Encoding: base64
Content-ID: <f_jz5qeqoz0>
X-Attachment-Id: f_jz5qeqoz0

ClsgNTQwNi41ODQ4NTFdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbIDU0
MDYuNTg0ODU1XSBERUJVR19MT0NLU19XQVJOX09OKHd3X2N0eC0+Y29udGVuZGluZ19sb2NrKQpb
IDU0MDYuNTg0ODYyXSBXQVJOSU5HOiBDUFU6IDIgUElEOiA0ODY1IGF0IGtlcm5lbC9sb2NraW5n
L211dGV4LmM6NzU3IF9fd3dfbXV0ZXhfbG9jay5jb25zdHByb3AuMCsweGIwZi8weDEwYzAKWyA1
NDA2LjU4NDg2NV0gTW9kdWxlcyBsaW5rZWQgaW46IG1hY3Z0YXAgbWFjdmxhbiB0YXAgcmZjb21t
IHh0X0NIRUNLU1VNIHh0X01BU1FVRVJBREUgbmZfbmF0X3RmdHAgbmZfY29ubnRyYWNrX3RmdHAg
dHVuIGJyaWRnZSBzdHAgbGxjIG5mX2Nvbm50cmFja19uZXRiaW9zX25zIG5mX2Nvbm50cmFja19i
cm9hZGNhc3QgeHRfQ1QgaXA2dF9SRUpFQ1QgbmZfcmVqZWN0X2lwdjYgaXA2dF9ycGZpbHRlciBp
cHRfUkVKRUNUIG5mX3JlamVjdF9pcHY0IHh0X2Nvbm50cmFjayBlYnRhYmxlX25hdCBpcDZ0YWJs
ZV9uYXQgaXA2dGFibGVfbWFuZ2xlIGlwNnRhYmxlX3JhdyBpcDZ0YWJsZV9zZWN1cml0eSBpcHRh
YmxlX25hdCBuZl9uYXQgaXB0YWJsZV9tYW5nbGUgaXB0YWJsZV9yYXcgaXB0YWJsZV9zZWN1cml0
eSBuZl9jb25udHJhY2sgbmZfZGVmcmFnX2lwdjYgbmZfZGVmcmFnX2lwdjQgbGliY3JjMzJjIGlw
X3NldCBuZm5ldGxpbmsgZWJ0YWJsZV9maWx0ZXIgZWJ0YWJsZXMgaXA2dGFibGVfZmlsdGVyIGlw
Nl90YWJsZXMgaXB0YWJsZV9maWx0ZXIgY21hYyBibmVwIHN1bnJwYyB2ZmF0IGZhdCBzbmRfaGRh
X2NvZGVjX3JlYWx0ZWsgc25kX2hkYV9jb2RlY19nZW5lcmljIGVkYWNfbWNlX2FtZCBsZWR0cmln
X2F1ZGlvIGt2bV9hbWQgc25kX2hkYV9jb2RlY19oZG1pIHNuZF9oZGFfaW50ZWwga3ZtIHJ0d3Bj
aSBzbmRfaGRhX2NvZGVjIHJ0dzg4IGlycWJ5cGFzcyBzbmRfaGRhX2NvcmUgc25kX3VzYl9hdWRp
byBtYWM4MDIxMSBzbmRfdXNibWlkaV9saWIgY3JjdDEwZGlmX3BjbG11bCB1dmN2aWRlbyBzbmRf
aHdkZXAgc25kX3Jhd21pZGkgY3JjMzJfcGNsbXVsIGJ0dXNiIHZpZGVvYnVmMl92bWFsbG9jIHZp
ZGVvYnVmMl9tZW1vcHMgc25kX3NlcSB2aWRlb2J1ZjJfdjRsMiBidHJ0bCBidGJjbSBnaGFzaF9j
bG11bG5pX2ludGVsIHNuZF9zZXFfZGV2aWNlIGJ0aW50ZWwgdmlkZW9idWYyX2NvbW1vbiB4cGFk
IGVlZXBjX3dtaSBqb3lkZXYgZmZfbWVtbGVzcwpbIDU0MDYuNTg0ODk1XSAgYmx1ZXRvb3RoIGNm
ZzgwMjExIHNuZF9wY20gYXN1c193bWkgdmlkZW9kZXYgc25kX3RpbWVyIHNwYXJzZV9rZXltYXAg
dmlkZW8gd21pX2Jtb2Ygc25kIGVjZGhfZ2VuZXJpYyBtYyBlY2Mgc291bmRjb3JlIGNjcCBrMTB0
ZW1wIHNwNTEwMF90Y28gcmZraWxsIGxpYmFyYzQgaTJjX3BpaXg0IGdwaW9fYW1kcHQgZ3Bpb19n
ZW5lcmljIGFjcGlfY3B1ZnJlcSBiaW5mbXRfbWlzYyBpcF90YWJsZXMgaGlkX2xvZ2l0ZWNoX2hp
ZHBwIGFtZGdwdSBjcmMzMmNfaW50ZWwgYW1kX2lvbW11X3YyIGdwdV9zY2hlZCB0dG0gZHJtX2tt
c19oZWxwZXIgaWdiIGRybSBudm1lIGRjYSBoaWRfbG9naXRlY2hfZGogaTJjX2FsZ29fYml0IG52
bWVfY29yZSB3bWkgcGluY3RybF9hbWQKWyA1NDA2LjU4NDkxNV0gQ1BVOiAyIFBJRDogNDg2NSBD
b21tOiBmaXJlZm94OmNzMCBOb3QgdGFpbnRlZCA1LjMuMC0wLnJjMy5naXQxLjIuZmMzMS54ODZf
NjQgIzEKWyA1NDA2LjU4NDkxN10gSGFyZHdhcmUgbmFtZTogU3lzdGVtIG1hbnVmYWN0dXJlciBT
eXN0ZW0gUHJvZHVjdCBOYW1lL1JPRyBTVFJJWCBYNDcwLUkgR0FNSU5HLCBCSU9TIDI0MDYgMDYv
MjEvMjAxOQpbIDU0MDYuNTg0OTIwXSBSSVA6IDAwMTA6X193d19tdXRleF9sb2NrLmNvbnN0cHJv
cC4wKzB4YjBmLzB4MTBjMApbIDU0MDYuNTg0OTIyXSBDb2RlOiAyOCAwMCA3NCAyOCBlOCA0MiAy
OSBhNiBmZiA4NSBjMCA3NCAxZiA4YiAwNSBmOCA2YSBlMCAwMCA4NSBjMCA3NSAxNSA0OCBjNyBj
NiA3MCAzNSAzMiA5MiA0OCBjNyBjNyBmMCA2NyAzMCA5MiBlOCBlOSA4NCA1YyBmZiA8MGY+IDBi
IDRkIDg5IDc0IDI0IDI4IGI4IGRkIGZmIGZmIGZmIDY1IDQ4IDhiIDE0IDI1IDQwIDhlIDAxIDAw
IDQ4ClsgNTQwNi41ODQ5MjRdIFJTUDogMDAxODpmZmZmYjczOGNjYTRmNzYwIEVGTEFHUzogMDAw
MTAyODYKWyA1NDA2LjU4NDkyNl0gUkFYOiAwMDAwMDAwMDAwMDAwMDAwIFJCWDogZmZmZjhlMTcz
MmUxMzMwMCBSQ1g6IDAwMDAwMDAwMDAwMDAwMDAKWyA1NDA2LjU4NDkyN10gUkRYOiAwMDAwMDAw
MDAwMDAwMDAyIFJTSTogMDAwMDAwMDAwMDAwMDAwMSBSREk6IDAwMDAwMDAwMDAwMDAyNDYKWyA1
NDA2LjU4NDkyOV0gUkJQOiBmZmZmYjczOGNjYTRmODIwIFIwODogMDAwMDAwMDAwMDAwMDAwMCBS
MDk6IDAwMDAwMDAwMDAwMDAwMDAKWyA1NDA2LjU4NDkzMV0gUjEwOiBmZmZmZmZmZjkzZDNmNzQw
IFIxMTogMDAwMDAwMDA5M2QzZjM3MyBSMTI6IGZmZmZiNzM4Y2NhNGZiOTAKWyA1NDA2LjU4NDkz
Ml0gUjEzOiBmZmZmYjczOGNjYTRmN2MwIFIxNDogZmZmZjhlMTcyZTBmYjI1OCBSMTU6IGZmZmY4
ZTE3MmUwZmIyNjAKWyA1NDA2LjU4NDkzNF0gRlM6ICAwMDAwN2ZjMmQ1YzZiNzAwKDAwMDApIEdT
OmZmZmY4ZTE4YmE0MDAwMDAoMDAwMCkga25sR1M6MDAwMDAwMDAwMDAwMDAwMApbIDU0MDYuNTg0
OTM1XSBDUzogIDAwMTAgRFM6IDAwMDAgRVM6IDAwMDAgQ1IwOiAwMDAwMDAwMDgwMDUwMDMzClsg
NTQwNi41ODQ5MzddIENSMjogMDAwMDdmZjU0YmJkMDAwMCBDUjM6IDAwMDAwMDA1YWQxMmEwMDAg
Q1I0OiAwMDAwMDAwMDAwMzQwNmUwClsgNTQwNi41ODQ5MzhdIENhbGwgVHJhY2U6ClsgNTQwNi41
ODQ5NDNdICA/IF9yYXdfc3Bpbl91bmxvY2tfaXJxKzB4MjkvMHg0MApbIDU0MDYuNTg0OTUxXSAg
PyB0dG1fbWVtX2V2aWN0X2ZpcnN0KzB4MWVkLzB4NGYwIFt0dG1dClsgNTQwNi41ODQ5NTVdICA/
IHd3X211dGV4X2xvY2tfaW50ZXJydXB0aWJsZSsweDQzLzB4YjAKWyA1NDA2LjU4NDk1N10gIHd3
X211dGV4X2xvY2tfaW50ZXJydXB0aWJsZSsweDQzLzB4YjAKWyA1NDA2LjU4NDk2MV0gIHR0bV9t
ZW1fZXZpY3RfZmlyc3QrMHgxZWQvMHg0ZjAgW3R0bV0KWyA1NDA2LjU4NDk2OV0gIHR0bV9ib19t
ZW1fc3BhY2UrMHgyMjkvMHgyYzAgW3R0bV0KWyA1NDA2LjU4NDk3NF0gIHR0bV9ib192YWxpZGF0
ZSsweGU1LzB4MTkwIFt0dG1dClsgNTQwNi41ODQ5NzldICA/IGxvY2tkZXBfaGFyZGlycXNfb24r
MHhmMC8weDE4MApbIDU0MDYuNTg1MDMzXSAgYW1kZ3B1X2NzX2JvX3ZhbGlkYXRlKzB4YWEvMHgx
YjAgW2FtZGdwdV0KWyA1NDA2LjU4NTA4Ml0gIGFtZGdwdV9jc192YWxpZGF0ZSsweDNiLzB4MjYw
IFthbWRncHVdClsgNTQwNi41ODUxMzFdICBhbWRncHVfY3NfbGlzdF92YWxpZGF0ZSsweDExMC8w
eDE4MCBbYW1kZ3B1XQpbIDU0MDYuNTg1MTg0XSAgYW1kZ3B1X2NzX2lvY3RsKzB4NWE5LzB4MWQx
MCBbYW1kZ3B1XQpbIDU0MDYuNTg1MTg5XSAgPyBzY2hlZF9jbG9jaysweDUvMHgxMApbIDU0MDYu
NTg1MjQ3XSAgPyBhbWRncHVfY3NfZmluZF9tYXBwaW5nKzB4MTIwLzB4MTIwIFthbWRncHVdClsg
NTQwNi41ODUyNjBdICBkcm1faW9jdGxfa2VybmVsKzB4YWEvMHhmMCBbZHJtXQpbIDU0MDYuNTg1
MjcxXSAgZHJtX2lvY3RsKzB4MjA4LzB4MzkwIFtkcm1dClsgNTQwNi41ODUzMTZdICA/IGFtZGdw
dV9jc19maW5kX21hcHBpbmcrMHgxMjAvMHgxMjAgW2FtZGdwdV0KWyA1NDA2LjU4NTMxOV0gID8g
c2NoZWRfY2xvY2tfY3B1KzB4Yy8weGMwClsgNTQwNi41ODUzMjJdICA/IGxvY2tkZXBfaGFyZGly
cXNfb24rMHhmMC8weDE4MApbIDU0MDYuNTg1MzY2XSAgYW1kZ3B1X2RybV9pb2N0bCsweDQ5LzB4
ODAgW2FtZGdwdV0KWyA1NDA2LjU4NTM3MV0gIGRvX3Zmc19pb2N0bCsweDQxMS8weDc1MApbIDU0
MDYuNTg1Mzc1XSAga3N5c19pb2N0bCsweDVlLzB4OTAKWyA1NDA2LjU4NTM3OF0gIF9feDY0X3N5
c19pb2N0bCsweDE2LzB4MjAKWyA1NDA2LjU4NTM4MV0gIGRvX3N5c2NhbGxfNjQrMHg1Yy8weGIw
ClsgNTQwNi41ODUzODVdICBlbnRyeV9TWVNDQUxMXzY0X2FmdGVyX2h3ZnJhbWUrMHg0OS8weGJl
ClsgNTQwNi41ODUzODddIFJJUDogMDAzMzoweDdmYzMwYjMxMDA3YgpbIDU0MDYuNTg1MzkwXSBD
b2RlOiAwZiAxZSBmYSA0OCA4YiAwNSAwZCA5ZSAwYyAwMCA2NCBjNyAwMCAyNiAwMCAwMCAwMCA0
OCBjNyBjMCBmZiBmZiBmZiBmZiBjMyA2NiAwZiAxZiA0NCAwMCAwMCBmMyAwZiAxZSBmYSBiOCAx
MCAwMCAwMCAwMCAwZiAwNSA8NDg+IDNkIDAxIGYwIGZmIGZmIDczIDAxIGMzIDQ4IDhiIDBkIGRk
IDlkIDBjIDAwIGY3IGQ4IDY0IDg5IDAxIDQ4ClsgNTQwNi41ODUzOTJdIFJTUDogMDAyYjowMDAw
N2ZjMmQ1YzZhMTE4IEVGTEFHUzogMDAwMDAyNDYgT1JJR19SQVg6IDAwMDAwMDAwMDAwMDAwMTAK
WyA1NDA2LjU4NTM5NF0gUkFYOiBmZmZmZmZmZmZmZmZmZmRhIFJCWDogMDAwMDdmYzJkNWM2YWFm
MCBSQ1g6IDAwMDA3ZmMzMGIzMTAwN2IKWyA1NDA2LjU4NTM5Nl0gUkRYOiAwMDAwN2ZjMmQ1YzZh
YWYwIFJTSTogMDAwMDAwMDBjMDE4NjQ0NCBSREk6IDAwMDAwMDAwMDAwMDAwMWYKWyA1NDA2LjU4
NTM5N10gUkJQOiAwMDAwN2ZjMmQ1YzZhYTcwIFIwODogMDAwMDdmYzJkNWM2YWQxMCBSMDk6IDAw
MDAwMDAwMDAwMDAwMzAKWyA1NDA2LjU4NTM5OF0gUjEwOiAwMDAwN2ZjMmQ1YzZhZDEwIFIxMTog
MDAwMDAwMDAwMDAwMDI0NiBSMTI6IDAwMDAwMDAwYzAxODY0NDQKWyA1NDA2LjU4NTQwMF0gUjEz
OiAwMDAwMDAwMDAwMDAwMDFmIFIxNDogMDAwMDdmYzJkNWM2YWFmMCBSMTU6IDAwMDAwMDAwMDAw
MDAwMWYKWyA1NDA2LjU4NTQwNF0gaXJxIGV2ZW50IHN0YW1wOiAxNTY5MjQ5NDcKWyA1NDA2LjU4
NTQwNl0gaGFyZGlycXMgbGFzdCAgZW5hYmxlZCBhdCAoMTU2OTI0OTQ3KTogWzxmZmZmZmZmZjkx
YjI0ZDE5Pl0gX3Jhd19zcGluX3VubG9ja19pcnErMHgyOS8weDQwClsgNTQwNi41ODU0MDhdIGhh
cmRpcnFzIGxhc3QgZGlzYWJsZWQgYXQgKDE1NjkyNDk0Nik6IFs8ZmZmZmZmZmY5MWIxZDE4OD5d
IF9fc2NoZWR1bGUrMHhjOC8weDkwMApbIDU0MDYuNTg1NDExXSBzb2Z0aXJxcyBsYXN0ICBlbmFi
bGVkIGF0ICgxNTY5MjM3NzYpOiBbPGZmZmZmZmZmOTFlMDAzNWQ+XSBfX2RvX3NvZnRpcnErMHgz
NWQvMHg0NWQKWyA1NDA2LjU4NTQxNF0gc29mdGlycXMgbGFzdCBkaXNhYmxlZCBhdCAoMTU2OTIz
NzY1KTogWzxmZmZmZmZmZjkxMGYxZTM3Pl0gaXJxX2V4aXQrMHhmNy8weDEwMApbIDU0MDYuNTg1
NDE1XSAtLS1bIGVuZCB0cmFjZSAyYjU4ZTEwMTNjMjgzNTM5IF0tLS0KWyA3NDE3LjE4NzQzMV0g
WW91bmdibG9vZF94NjR2ICgxNDY1NykgdXNlZCBncmVhdGVzdCBzdGFjayBkZXB0aDogMTA1MDQg
Ynl0ZXMgbGVmdApbIDc0MTcuMTkwODcyXSBZb3VuZ2Jsb29kX3g2NHYgKDE0NjU0KSB1c2VkIGdy
ZWF0ZXN0IHN0YWNrIGRlcHRoOiAxMDI0OCBieXRlcyBsZWZ0ClsxMTY2NC45NDk0MzddIG5mX2Nv
bm50cmFjazogZGVmYXVsdCBhdXRvbWF0aWMgaGVscGVyIGFzc2lnbm1lbnQgaGFzIGJlZW4gdHVy
bmVkIG9mZiBmb3Igc2VjdXJpdHkgcmVhc29ucyBhbmQgQ1QtYmFzZWQgIGZpcmV3YWxsIHJ1bGUg
bm90IGZvdW5kLiBVc2UgdGhlIGlwdGFibGVzIENUIHRhcmdldCB0byBhdHRhY2ggaGVscGVycyBp
bnN0ZWFkLgpbMTUyOTguNjk4MjkzXSBwZXJmOiBpbnRlcnJ1cHQgdG9vayB0b28gbG9uZyAoMjUw
MyA+IDI1MDApLCBsb3dlcmluZyBrZXJuZWwucGVyZl9ldmVudF9tYXhfc2FtcGxlX3JhdGUgdG8g
NzkwMDAKWzE5NjU2LjA0NDExM10gc2hvd19zaWduYWxfbXNnOiAxIGNhbGxiYWNrcyBzdXBwcmVz
c2VkCg==
--000000000000800e78058fc58002--

