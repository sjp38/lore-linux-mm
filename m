Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA3EA6B0006
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 18:50:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v2so4718432pgv.23
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 15:50:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q11-v6sor2686762plk.98.2018.03.02.15.50.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 15:50:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
References: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
From: Dexuan-Linux Cui <dexuan.linux@gmail.com>
Date: Fri, 2 Mar 2018 15:50:13 -0800
Message-ID: <CAA42JLZRxCGSsW5FKpH3AjZGbaUyrcRPdVBtMQcc4ZcxKNuDQw@mail.gmail.com>
Subject: Re: "x86/boot/compressed/64: Prepare trampoline memory" breaks boot
 on Zotac CI-321
Content-Type: multipart/alternative; boundary="0000000000003c5541056676a325"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiner Kallweit <hkallweit1@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dexuan Cui <decui@microsoft.com>

--0000000000003c5541056676a325
Content-Type: text/plain; charset="UTF-8"

On Fri, Mar 2, 2018 at 12:57 PM, Heiner Kallweit <hkallweit1@gmail.com>
wrote:

> Recently my Mini PC Zotac CI-321 started to reboot immediately before
> anything was written to the console.
>
> Bisecting lead to b91993a87aff "x86/boot/compressed/64: Prepare
> trampoline memory" being the change breaking boot.
>
> If you need any more information, please let me know.
>
> Rgds, Heiner
>

This may fix the issue: https://lkml.org/lkml/2018/2/13/668

Kirill posted a v2 patchset 3 days ago and I suppose the patchset should
include the fix.

-- Dexuan

--0000000000003c5541056676a325
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On F=
ri, Mar 2, 2018 at 12:57 PM, Heiner Kallweit <span dir=3D"ltr">&lt;<a href=
=3D"mailto:hkallweit1@gmail.com" target=3D"_blank">hkallweit1@gmail.com</a>=
&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px=
 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">Rec=
ently my Mini PC Zotac CI-321 started to reboot immediately before<br>
anything was written to the console.<br>
<br>
Bisecting lead to b91993a87aff &quot;x86/boot/compressed/64: Prepare<br>
trampoline memory&quot; being the change breaking boot.<br>
<br>
If you need any more information, please let me know.<br>
<br>
Rgds, Heiner<br>
</blockquote></div><br></div><div class=3D"gmail_extra">This may fix the is=
sue: <a href=3D"https://lkml.org/lkml/2018/2/13/668">https://lkml.org/lkml/=
2018/2/13/668</a></div><div class=3D"gmail_extra"><br></div><div class=3D"g=
mail_extra">

<span style=3D"color:rgb(119,119,119);font-family:arial,sans-serif;font-siz=
e:12.8px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:=
normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0=
px;text-transform:none;white-space:nowrap;word-spacing:0px;background-color=
:rgb(255,255,255);text-decoration-style:initial;text-decoration-color:initi=
al;float:none;display:inline">Kirill posted a v2 patchset 3 days ago and I =
suppose the patchset should include the fix.</span></div><div class=3D"gmai=
l_extra"><span style=3D"color:rgb(119,119,119);font-family:arial,sans-serif=
;font-size:12.8px;font-style:normal;font-variant-ligatures:normal;font-vari=
ant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text=
-indent:0px;text-transform:none;white-space:nowrap;word-spacing:0px;backgro=
und-color:rgb(255,255,255);text-decoration-style:initial;text-decoration-co=
lor:initial;float:none;display:inline"><br></span></div><div class=3D"gmail=
_extra"><span style=3D"color:rgb(119,119,119);font-size:12.8px;white-space:=
nowrap">-- Dexuan</span><br></div></div>

--0000000000003c5541056676a325--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
