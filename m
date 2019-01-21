Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E19B38E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:48:53 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s5so17596320iom.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:48:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11sor21790833itb.1.2019.01.21.13.48.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 13:48:53 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsMfWW_jA4vVfzr8MOLfqj2kz_AYyn5Ve48dxe1DtAbWXw@mail.gmail.com>
 <f3647d02-083c-d3f8-597f-9a98095d20f1@amd.com>
In-Reply-To: <f3647d02-083c-d3f8-597f-9a98095d20f1@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Tue, 22 Jan 2019 02:48:41 +0500
Message-ID: <CABXGCsNbjYvoc=QtX0fbW0V6T8dYzxn29yUGDD0CieL5s9GCtw@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, amd-gfx list <amd-gfx@lists.freedesktop.org>, "Wentland, Harry" <Harry.Wentland@amd.com>

On Mon, 21 Jan 2019 at 22:00, Grodzovsky, Andrey
<Andrey.Grodzovsky@amd.com> wrote:
>
> + Harry
>
> Looks like this is happening during GPU reset due to job time out. I would first try to reproduce this just with a plain reset from sysfs.
> Mikhail, also please provide add2line for dce110_setup_audio_dto.isra.8+0x171

$ eu-addr2line -e
/lib/debug/lib/modules/5.0.0-0.rc2.git4.3.fc30.x86_64/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.debug
dce110_setup_audio_dto.isra.8+0x171
drivers/gpu/drm/amd/amdgpu/../display/dc/dce110/dce110_hw_sequencer.c:1996:25

Thanks, I hope this helps.

--
Best Regards,
Mike Gavrilov.
