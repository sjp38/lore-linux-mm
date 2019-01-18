Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Fri, 18 Jan 2019 15:38:48 +0530
Message-ID: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
Subject: Need help: how to locate failure from irq_chip subsystem
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, kernelnewbies@kernelnewbies.org, Pintu Kumar <pintu.ping@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi All,

Currently, I am trying to debug a boot up crash on some qualcomm
snapdragon arm64 board with kernel 4.9.
I could find the cause of the failure, but I am unable to locate from
which subsystem/drivers this is getting triggered.
If you have any ideas or suggestions to locate the issue, please let me know.

This is the snapshot of crash logs:
[    6.907065] Unable to handle kernel NULL pointer dereference at
virtual address 00000000
[    6.973938] PC is at 0x0
[    6.976503] LR is at __ipipe_ack_fasteoi_irq+0x28/0x38
[    7.151078] Process qmp_aop (pid: 24, stack limit = 0xfffffffbedc18000)
[    7.242668] [<          (null)>]           (null)
[    7.247416] [<ffffff9469f8d2e0>] __ipipe_dispatch_irq+0x78/0x340
[    7.253469] [<ffffff9469e81564>] __ipipe_grab_irq+0x5c/0xd0
[    7.341538] [<ffffff9469e81d68>] gic_handle_irq+0xc0/0x154

[    6.288581] [PINTU]: __ipipe_ack_fasteoi_irq - called
[    6.293698] [PINTU]: __ipipe_ack_fasteoi_irq:
desc->irq_data.chip->irq_hold is NULL

When I check, I found that the irq_hold implementation is missing in
one of the irq_chip driver (expected by ipipe), which I am supposed to
implement.

But I am unable to locate which irq_chip driver.
If there are any good techniques to locate this in kernel, please help.


Thanks,
Pintu
