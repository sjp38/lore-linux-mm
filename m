Date: Tue, 18 Mar 2003 22:49:25 +0300
From: "Ruslan U. Zakirov" <cubic@wr.miee.ru>
Reply-To: "Ruslan U. Zakirov" <cubic@wr.miee.ru>
Message-ID: <1731494377120.20030318224925@wr.miee.ru>
Subject: Re[2]: 2.5.65-mm1
In-Reply-To: <87bs08vfkg.fsf@lapper.ihatent.com>
References: <20030318031104.13fb34cc.akpm@digeo.com>
 <87adfs4sqk.fsf@lapper.ihatent.com> <87bs08vfkg.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel-owner@vger.kernel.org, Alexander Hoogerhuis <alexh@ihatent.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, Adam Belay <ambx1@neo.rr.com>
List-ID: <linux-mm.kvack.org>

AH> Alexander Hoogerhuis <alexh@ihatent.com> writes:
>> Andrew Morton <akpm@digeo.com> writes:
>> >
>> > [SNIP]
>> >
>> 
>> [SNIP MYSELF]
>>
AH> And this one when probing for my PCIC:

AH> Intel PCIC probe: PNP <6>pnp: res: The PnP device '00:0f' is already
AH> active.
Hello, Alexandre and other.
       This error is not mm specific.
This was brought with latest PnP changes.
As I've understood that latest PnP Layer activates all devices during layer
initialisation, but I don't know how it could be if we don't register
pnp_driver. With first look I didn't find this runpaths. I'll try to
review all changes.
Adam know absolutly right solution in this case, I think :)
                       Best regards, Ruslan.

                         mailto:cubic@wr.miee.ru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
