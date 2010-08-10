Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 90D23600044
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 02:27:08 -0400 (EDT)
Received: by vws16 with SMTP id 16so8667413vws.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 23:27:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C470E69.7020900@kernel.org>
References: <861vaxjij8.fsf@peer.zerties.org> <4C470E69.7020900@kernel.org>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Tue, 10 Aug 2010 02:26:45 -0400
Message-ID: <AANLkTik-DkN7gUwTuquWxA-iziHyonG9ijWb4=K8WUo=@mail.gmail.com>
Subject: Re: Dead Config in mm/percpu.c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christian Dietrich <stettberger@dokucode.de>, David Howells <dhowells@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 11:12, Tejun Heo wrote:
> On 07/21/2010 11:22 AM, Christian Dietrich wrote:
>> We found, that CONFIG_NEED_PER_CPU_KM is a dead symbol, so it isn't defi=
ned
>> anywhere. Cause of that the percpu_km.c is never included anywhere. Is
>> this a intended dead symbol, for use in out of tree development, or is
>> this just an error?
>
> Oh, it's new code waiting to be used. =C2=A0It's for cases where SMP is
> used w/o MMU. =C2=A0IIRC, it was blackfin.

yep.  unfortunately, we're in the middle of making a release on top of
2.6.34.x.  hopefully we should be able to get a patch out for the
2.6.37 merge window at the latest.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
